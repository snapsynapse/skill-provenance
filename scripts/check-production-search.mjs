#!/usr/bin/env node
// skill_bundle: portfolio-search-indexing-audit
// file_role: asset
// version: 6
// version_date: 2026-11-08
// previous_version: 5
// change_summary: Single-pass XML entity decode() fixes CodeQL js/double-escaping (&amp;lt; no longer becomes <); repository contract remains v4.
// Upstream: portfolio-search-indexing-audit contract v4.
// Release-triggered HTTP validation. Exit 2 means infrastructure is unavailable.
'use strict';

import fs from 'node:fs';
import path from 'node:path';

const CONFIG_ARG = process.argv.find(value => value.startsWith('--config='));
const BASE_ARG = process.argv.find(value => value.startsWith('--base='));
const JSON_OUTPUT = process.argv.includes('--json');
const ROOT = process.cwd();
let defects = 0;
let infrastructure = 0;

function report(kind, message) {
    if (kind === 'defect') defects++;
    else infrastructure++;
    console.error(`${kind === 'defect' ? 'LIVE' : 'NETWORK'}  ${message}`);
}

const XML_ENTITIES = { '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&#39;': "'" };
function decode(value) {
    return String(value || '').replace(/&(?:amp|lt|gt|quot|#39);/g, (entity) => XML_ENTITIES[entity]);
}

function loadConfig() {
    const configPath = path.resolve(ROOT, CONFIG_ARG ? CONFIG_ARG.slice(9) : 'search-audit.config.json');
    try {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        if (![2, 3, 4].includes(config.contractVersion)) throw new Error('contractVersion must be 2, 3, or 4');
        const canonical = new URL(config.canonicalOrigin);
        if (canonical.protocol !== 'https:' || canonical.pathname !== '/' || canonical.hostname.startsWith('www.')) {
            throw new Error('canonicalOrigin must be a bare HTTPS origin with trailing slash');
        }
        return { ...config, canonicalOrigin: canonical.href };
    } catch (error) {
        report('infrastructure', `configuration failed: ${error.message}`);
        return null;
    }
}

const config = loadConfig();
if (!config) process.exit(2);
const canonicalOrigin = new URL(config.canonicalOrigin);
const base = new URL(BASE_ARG ? BASE_ARG.slice(7) : canonicalOrigin.href);
if (!base.pathname.endsWith('/')) base.pathname += '/';
const production = base.href === canonicalOrigin.href;

async function request(url) {
    let lastError;
    for (let attempt = 1; attempt <= 3; attempt++) {
        try {
            return await fetch(url, {
                redirect: 'follow',
                headers: { 'user-agent': 'portfolio-search-contract/4' },
                signal: AbortSignal.timeout(15000)
            });
        } catch (error) {
            lastError = error;
            if (attempt < 3) await new Promise(resolve => setTimeout(resolve, attempt * 150));
        }
    }
    report('infrastructure', `${url}: fetch failed after 3 attempts: ${lastError?.cause?.message || lastError?.message || 'unknown error'}`);
    return null;
}

function deployedUrl(canonical) {
    return production ? canonical : new URL(new URL(canonical).pathname.replace(/^\//, ''), base).href;
}

function false404(body, url) {
    for (const pattern of config.hosted404Patterns || []) {
        if (body.toLowerCase().includes(String(pattern).toLowerCase())) {
            report('defect', `${url}: response contains hosted 404 marker ${JSON.stringify(pattern)}`);
            return true;
        }
    }
    return false;
}

async function fetchText(url, rule = {}) {
    const response = await request(url);
    if (!response) return null;
    const body = await response.text();
    if (!response.ok) report('defect', `${url}: HTTP ${response.status}`);
    const type = response.headers.get('content-type') || '';
    if (rule.contentTypes?.length && !rule.contentTypes.some(expected => type.toLowerCase().includes(expected.toLowerCase()))) {
        report('defect', `${url}: unexpected content-type ${type || '(missing)'}`);
    }
    for (const required of rule.contains || []) {
        if (!body.includes(required)) report('defect', `${url}: missing required text ${JSON.stringify(required)}`);
    }
    false404(body, url);
    return { response, body, type };
}

const sitemapBodies = new Map();

async function fetchSitemap(canonical, seen = new Set()) {
    if (seen.has(canonical)) return;
    seen.add(canonical);
    const target = deployedUrl(canonical);
    const result = await fetchText(target, { contentTypes: ['xml'] });
    if (!result) return;
    sitemapBodies.set(canonical, result.body);
    if (/<sitemapindex\b/i.test(result.body)) {
        for (const match of result.body.matchAll(/<sitemap>[\s\S]*?<loc>([^<]+)<\/loc>[\s\S]*?<\/sitemap>/gi)) {
            let child;
            try { child = new URL(decode(match[1])); }
            catch { report('defect', `${canonical}: invalid child sitemap URL ${match[1]}`); continue; }
            if (child.origin !== canonicalOrigin.origin) {
                report('defect', `${canonical}: child sitemap uses noncanonical origin ${child.href}`);
                continue;
            }
            await fetchSitemap(child.href, seen);
        }
    }
}

for (const rule of config.requiredFiles || []) {
    await fetchText(new URL(rule.path.replace(/^\//, ''), base).href, rule);
}

for (const pathname of config.expectedNotFoundPaths || []) {
    if (typeof pathname !== 'string' || !pathname.startsWith('/') || pathname.includes('?') || pathname.includes('#')) {
        report('infrastructure', `invalid expected-not-found path: ${JSON.stringify(pathname)}`);
        continue;
    }
    const target = new URL(pathname.replace(/^\//, ''), base).href;
    const response = await request(target);
    if (!response) continue;
    if (response.status !== 404) report('defect', `${target}: expected HTTP 404, received ${response.status}`);
    if (response.url !== target) report('defect', `${target}: expected no redirect, final URL is ${response.url}`);
}

for (const sitemap of config.sitemaps || []) {
    await fetchSitemap(new URL(sitemap.replace(/^\//, ''), canonicalOrigin).href);
}

const canonicals = [];
const sitemapLastmods = new Map();
for (const [sitemap, body] of sitemapBodies) {
    for (const match of body.matchAll(/<url>([\s\S]*?)<\/url>/gi)) {
        const canonical = decode(match[1].match(/<loc>([^<]+)<\/loc>/i)?.[1]);
        const lastmod = match[1].match(/<lastmod>([^<]+)<\/lastmod>/i)?.[1]?.trim();
        if (!canonical) {
            report('defect', `${sitemap}: URL entry is missing loc`);
            continue;
        }
        let url;
        try { url = new URL(canonical); }
        catch { report('defect', `${sitemap}: invalid page location ${canonical}`); continue; }
        if (url.origin !== canonicalOrigin.origin || url.href !== canonical) {
            report('defect', `${sitemap}: noncanonical page location ${canonical}`);
        }
        canonicals.push(canonical);
        sitemapLastmods.set(canonical, lastmod);
    }
}
if (!canonicals.length) report('infrastructure', 'live sitemaps contain no page locations');

function repositoryCanonicals() {
    const output = path.resolve(ROOT, config.outputDir || '');
    const urls = new Set();
    const seen = new Set();
    function parse(relative) {
        const file = path.resolve(output, relative);
        if (seen.has(file)) return;
        seen.add(file);
        if (!file.startsWith(output + path.sep) && file !== output) {
            report('infrastructure', `repository sitemap escapes output directory: ${relative}`);
            return;
        }
        let xml;
        try { xml = fs.readFileSync(file, 'utf8'); }
        catch (error) {
            report('infrastructure', `cannot read repository sitemap ${path.relative(ROOT, file)}: ${error.message}`);
            return;
        }
        if (/<sitemapindex\b/i.test(xml)) {
            for (const match of xml.matchAll(/<sitemap>[\s\S]*?<loc>([^<]+)<\/loc>[\s\S]*?<\/sitemap>/gi)) {
                let child;
                try { child = new URL(decode(match[1])); }
                catch { report('defect', `${relative}: invalid repository child sitemap URL ${decode(match[1])}`); continue; }
                if (child.origin !== canonicalOrigin.origin) {
                    report('defect', `${relative}: repository child sitemap uses noncanonical origin ${child.href}`);
                    continue;
                }
                parse(child.pathname.replace(/^\//, ''));
            }
            return;
        }
        for (const match of xml.matchAll(/<url>[\s\S]*?<loc>([^<]+)<\/loc>[\s\S]*?<\/url>/gi)) {
            const canonical = decode(match[1]);
            let url;
            try { url = new URL(canonical); }
            catch { report('defect', `${relative}: invalid repository page location ${canonical}`); continue; }
            if (url.origin !== canonicalOrigin.origin || url.href !== canonical) {
                report('defect', `${relative}: noncanonical repository page location ${canonical}`);
            }
            urls.add(canonical);
        }
    }
    for (const sitemap of config.sitemaps || []) parse(sitemap);
    return urls;
}

if (config.compareRepositorySitemaps !== false) {
    const repository = repositoryCanonicals();
    const deployed = new Set(canonicals);
    if (!repository.size) report('infrastructure', 'repository sitemaps contain no page locations for deployment comparison');
    for (const canonical of repository) {
        if (!deployed.has(canonical)) report('defect', `deployment sitemap is missing repository URL ${canonical}`);
    }
    for (const canonical of deployed) {
        if (!repository.has(canonical)) report('defect', `deployment sitemap has URL absent from repository ${canonical}`);
    }
}

function jsonLd(html, url) {
    const blocks = [...html.matchAll(/<script\b[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi)];
    const pathname = new URL(url).pathname;
    const required = config.requireJsonLd === true || (config.jsonLdRequiredPaths || []).includes(pathname);
    if (!blocks.length && required) report('defect', `${url}: missing JSON-LD`);
    for (const block of blocks) {
        try { JSON.parse(block[1]); }
        catch (error) { report('defect', `${url}: invalid JSON-LD: ${error.message}`); }
    }
}

function collectDateModified(value, dates = []) {
    if (Array.isArray(value)) {
        for (const item of value) collectDateModified(item, dates);
    } else if (value && typeof value === 'object') {
        if (typeof value.dateModified === 'string') dates.push(value.dateModified.slice(0, 10));
        for (const child of Object.values(value)) collectDateModified(child, dates);
    }
    return dates;
}

function lastmodAgreement(html, url, sitemapLastmod) {
    const pathname = new URL(url).pathname;
    if (!(config.lastmodAgreementPaths || []).includes(pathname)) return;
    const meta = html.match(/<meta\b[^>]*property=["']article:modified_time["'][^>]*content=["']([^"']+)["']/i)?.[1]
        || html.match(/<meta\b[^>]*content=["']([^"']+)["'][^>]*property=["']article:modified_time["']/i)?.[1];
    if (!meta) report('defect', `${url}: missing article:modified_time`);
    else if (meta.slice(0, 10) !== sitemapLastmod) report('defect', `${url}: article:modified_time ${meta.slice(0, 10)} does not equal sitemap lastmod ${sitemapLastmod}`);
    const dates = [];
    for (const block of html.matchAll(/<script\b[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi)) {
        try { collectDateModified(JSON.parse(block[1]), dates); } catch { /* reported by jsonLd */ }
    }
    if (!dates.length) report('defect', `${url}: JSON-LD is missing dateModified`);
    else if (!dates.includes(sitemapLastmod)) report('defect', `${url}: JSON-LD dateModified ${dates.join(', ')} does not equal sitemap lastmod ${sitemapLastmod}`);
}

async function checkPage(canonical) {
    const target = deployedUrl(canonical);
    const result = await fetchText(target, { contentTypes: ['text/html'] });
    if (!result) return;
    if (result.response.url !== target) report('defect', `${target}: final URL is ${result.response.url}`);
    const html = result.body;
    const pageCanonical = html.match(/<link\b[^>]*rel=["']canonical["'][^>]*href=["']([^"']+)["']/i)?.[1]
        || html.match(/<link\b[^>]*href=["']([^"']+)["'][^>]*rel=["']canonical["']/i)?.[1];
    if (pageCanonical !== canonical) report('defect', `${target}: canonical ${pageCanonical || '(missing)'} does not equal ${canonical}`);
    if (/<meta\b[^>]*name=["']robots["'][^>]*content=["'][^"']*noindex/i.test(html)) {
        report('defect', `${target}: sitemap page is noindex`);
    }
    jsonLd(html, target);
    lastmodAgreement(html, target, sitemapLastmods.get(canonical));
}

async function mapLimit(items, limit, fn) {
    let index = 0;
    await Promise.all(Array.from({ length: Math.min(limit, items.length) }, async () => {
        while (index < items.length) await fn(items[index++]);
    }));
}

await mapLimit([...new Set(canonicals)], 8, checkPage);

if (production) {
    for (const redirect of config.redirects || []) {
        const response = await request(redirect.from);
        if (response && response.url !== redirect.to) {
            report('defect', `${redirect.from}: final URL is ${response.url}, expected ${redirect.to}`);
        }
    }
}

const summary = {
    contractVersion: config.contractVersion,
    base: base.href,
    pages: new Set(canonicals).size,
    defects,
    infrastructure
};
if (JSON_OUTPUT) console.log(JSON.stringify(summary));
else console.log(`check-production-search: ${summary.pages} sitemap pages at ${base.href}, ${defects} defects, ${infrastructure} infrastructure failures`);
process.exit(infrastructure ? 2 : defects ? 1 : 0);
