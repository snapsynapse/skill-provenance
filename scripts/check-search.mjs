#!/usr/bin/env node
// skill_bundle: portfolio-search-indexing-audit
// file_role: asset
// version: 6
// version_date: 2026-11-08
// previous_version: 5
// change_summary: Single-pass XML entity decode() fixes CodeQL js/double-escaping (&amp;lt; no longer becomes <); repository contract remains v4.
// Upstream: portfolio-search-indexing-audit contract v4.
// Vendored repository script. Adapt locally and retain contractVersion.
'use strict';

import fs from 'node:fs';
import path from 'node:path';

const CONFIG_ARG = process.argv.find(value => value.startsWith('--config='));
const JSON_OUTPUT = process.argv.includes('--json');
const ROOT = process.cwd();
let defects = 0;
let infrastructure = 0;

function report(kind, message) {
    if (kind === 'defect') defects++;
    else infrastructure++;
    console.error(`${kind === 'defect' ? 'SEARCH' : 'SETUP'}  ${message}`);
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
        if (!config.canonicalOrigin || !config.outputDir || !Array.isArray(config.sitemaps)) {
            throw new Error('canonicalOrigin, outputDir, and sitemaps are required');
        }
        const origin = new URL(config.canonicalOrigin);
        if (origin.protocol !== 'https:' || origin.pathname !== '/' || origin.search || origin.hash) {
            throw new Error('canonicalOrigin must be a bare HTTPS origin with trailing slash');
        }
        if (origin.hostname.startsWith('www.')) throw new Error('canonicalOrigin must use the bare host');
        return { ...config, canonicalOrigin: origin.href, configPath };
    } catch (error) {
        report('infrastructure', `configuration failed: ${error.message}`);
        return null;
    }
}

const config = loadConfig();
if (!config) process.exit(2);
const OUTPUT = path.resolve(ROOT, config.outputDir);
if (!fs.existsSync(OUTPUT)) {
    report('infrastructure', `output directory is missing: ${OUTPUT}`);
    process.exit(2);
}

const origin = new URL(config.canonicalOrigin);
const today = new Date().toISOString().slice(0, 10);
const sitemapUrls = new Set();
const entries = [];

function routeFile(pathname) {
    if (pathname === '/') return path.join(OUTPUT, 'index.html');
    const relative = pathname.replace(/^\//, '');
    if (pathname.endsWith('/')) return path.join(OUTPUT, relative, 'index.html');
    const direct = path.join(OUTPUT, relative);
    if (fs.existsSync(direct)) return direct;
    if (fs.existsSync(`${direct}.html`)) return `${direct}.html`;
    return direct;
}

function parseSitemapFile(relative, seen = new Set()) {
    const file = path.resolve(OUTPUT, relative);
    if (seen.has(file)) return;
    seen.add(file);
    if (!file.startsWith(OUTPUT + path.sep) && file !== OUTPUT) {
        report('infrastructure', `sitemap escapes output directory: ${relative}`);
        return;
    }
    let xml;
    try { xml = fs.readFileSync(file, 'utf8'); }
    catch (error) {
        report('infrastructure', `cannot read sitemap ${path.relative(ROOT, file)}: ${error.message}`);
        return;
    }
    if (/<sitemapindex\b/i.test(xml)) {
        for (const match of xml.matchAll(/<sitemap>[\s\S]*?<loc>([^<]+)<\/loc>[\s\S]*?<\/sitemap>/gi)) {
            let child;
            try { child = new URL(decode(match[1])); }
            catch { report('defect', `${relative}: invalid child sitemap URL ${decode(match[1])}`); continue; }
            if (child.origin !== origin.origin) {
                report('defect', `${relative}: child sitemap uses noncanonical origin ${child.href}`);
                continue;
            }
            parseSitemapFile(child.pathname.replace(/^\//, ''), seen);
        }
        return;
    }
    for (const match of xml.matchAll(/<url>([\s\S]*?)<\/url>/gi)) {
        const block = match[1];
        entries.push({
            loc: decode(block.match(/<loc>([^<]+)<\/loc>/i)?.[1]),
            lastmod: decode(block.match(/<lastmod>([^<]+)<\/lastmod>/i)?.[1]),
            source: relative
        });
    }
}

for (const sitemap of config.sitemaps) parseSitemapFile(sitemap);
if (!entries.length) report('infrastructure', 'configured sitemaps contain no URL entries');

function first(html, regex) {
    return decode(html.match(regex)?.[1] || '').trim();
}

function jsonLd(html, rel, pathname) {
    const blocks = [...html.matchAll(/<script\b[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi)];
    const required = config.requireJsonLd === true || (config.jsonLdRequiredPaths || []).includes(pathname);
    if (!blocks.length && required) report('defect', `${rel}: missing JSON-LD`);
    for (const block of blocks) {
        try { JSON.parse(block[1]); }
        catch (error) { report('defect', `${rel}: invalid JSON-LD: ${error.message}`); }
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

function lastmodAgreement(html, rel, pathname, sitemapLastmod) {
    if (!(config.lastmodAgreementPaths || []).includes(pathname)) return;
    const meta = first(html, /<meta\b[^>]*property=["']article:modified_time["'][^>]*content=["']([^"']+)["']/i)
        || first(html, /<meta\b[^>]*content=["']([^"']+)["'][^>]*property=["']article:modified_time["']/i);
    if (!meta) report('defect', `${rel}: missing article:modified_time`);
    else if (meta.slice(0, 10) !== sitemapLastmod) report('defect', `${rel}: article:modified_time ${meta.slice(0, 10)} does not equal sitemap lastmod ${sitemapLastmod}`);
    const dates = [];
    for (const block of html.matchAll(/<script\b[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi)) {
        try { collectDateModified(JSON.parse(block[1]), dates); } catch { /* reported by jsonLd */ }
    }
    if (!dates.length) report('defect', `${rel}: JSON-LD is missing dateModified`);
    else if (!dates.includes(sitemapLastmod)) report('defect', `${rel}: JSON-LD dateModified ${dates.join(', ')} does not equal sitemap lastmod ${sitemapLastmod}`);
}

function visibleWords(html) {
    const main = html.match(/<main\b[^>]*>([\s\S]*?)<\/main>/i)?.[1] || html;
    const text = main.replace(/<(script|style|svg)\b[\s\S]*?<\/\1>/gi, ' ')
        .replace(/<!--[\s\S]*?-->/g, ' ').replace(/<[^>]+>/g, ' ')
        .replace(/&[a-zA-Z0-9#]+;/g, ' ');
    return text.match(/[\p{L}\p{N}][\p{L}\p{N}'’-]{0,}/gu)?.length || 0;
}

function exempt(pathname) {
    return (config.thinPageExemptions || []).some(pattern => new RegExp(pattern).test(pathname));
}

const pages = new Map();
const titles = new Map();
const descriptions = new Map();

for (const entry of entries) {
    let url;
    try { url = new URL(entry.loc); }
    catch { report('defect', `${entry.source}: invalid location ${entry.loc}`); continue; }
    if (url.origin !== origin.origin || url.href !== entry.loc) report('defect', `${entry.source}: noncanonical location ${entry.loc}`);
    if (sitemapUrls.has(entry.loc)) report('defect', `${entry.source}: duplicate location ${entry.loc}`);
    sitemapUrls.add(entry.loc);
    if (!/^\d{4}-\d{2}-\d{2}$/.test(entry.lastmod || '')) {
        report('defect', `${entry.loc}: missing or invalid lastmod`);
    } else if (entry.lastmod > today) {
        report('defect', `${entry.loc}: lastmod ${entry.lastmod} is in the future`);
    }
    const file = routeFile(url.pathname);
    const rel = path.relative(ROOT, file);
    if (!fs.existsSync(file)) {
        report('defect', `${entry.loc}: no generated file at ${rel}`);
        continue;
    }
    const html = fs.readFileSync(file, 'utf8');
    pages.set(entry.loc, { html, rel, pathname: url.pathname });
    const canonical = first(html, /<link\b[^>]*rel=["']canonical["'][^>]*href=["']([^"']+)["']/i)
        || first(html, /<link\b[^>]*href=["']([^"']+)["'][^>]*rel=["']canonical["']/i);
    if (canonical !== entry.loc) report('defect', `${rel}: canonical ${canonical || '(missing)'} does not equal ${entry.loc}`);
    if (/<meta\b[^>]*name=["']robots["'][^>]*content=["'][^"']*noindex/i.test(html)) report('defect', `${rel}: sitemap page is noindex`);
    const title = first(html, /<title>([\s\S]*?)<\/title>/i);
    const description = first(html, /<meta\b[^>]*name=["']description["'][^>]*content=["']([^"']+)["']/i)
        || first(html, /<meta\b[^>]*content=["']([^"']+)["'][^>]*name=["']description["']/i);
    if (!title) report('defect', `${rel}: missing title`);
    else if (titles.has(title)) report('defect', `${rel}: duplicate title also used by ${titles.get(title)}`);
    else titles.set(title, rel);
    if (!description) report('defect', `${rel}: missing meta description`);
    else if (descriptions.has(description)) report('defect', `${rel}: duplicate description also used by ${descriptions.get(description)}`);
    else descriptions.set(description, rel);
    const words = visibleWords(html);
    const minimum = Number(config.minimumWords ?? 120);
    if (!exempt(url.pathname) && words < minimum) report('defect', `${rel}: ${words} visible words; expected at least ${minimum}`);
    jsonLd(html, rel, url.pathname);
    lastmodAgreement(html, rel, url.pathname, entry.lastmod);
}

for (const rule of config.requiredFiles || []) {
    const file = path.resolve(OUTPUT, rule.path.replace(/^\//, ''));
    if (!file.startsWith(OUTPUT + path.sep)) {
        report('infrastructure', `required file escapes output directory: ${rule.path}`);
        continue;
    }
    if (!fs.existsSync(file)) {
        report('defect', `${rule.path}: required output is missing`);
        continue;
    }
    const text = fs.readFileSync(file).toString('utf8');
    for (const required of rule.contains || []) {
        if (!text.includes(required)) report('defect', `${rule.path}: missing required text ${JSON.stringify(required)}`);
    }
}

for (const pathname of config.expectedNoindex || []) {
    const url = new URL(pathname, origin);
    if (sitemapUrls.has(url.href)) report('defect', `${url.href}: expected noindex route appears in sitemap`);
    const file = routeFile(url.pathname);
    if (!fs.existsSync(file)) {
        report('defect', `${pathname}: expected noindex output is missing`);
        continue;
    }
    const html = fs.readFileSync(file, 'utf8');
    if (!/<meta\b[^>]*name=["']robots["'][^>]*content=["'][^"']*noindex/i.test(html)) {
        report('defect', `${path.relative(ROOT, file)}: expected noindex meta is missing`);
    }
}

function internal(href) {
    if (!href || /^(mailto:|tel:|data:|javascript:)/i.test(href)) return null;
    let url;
    try { url = new URL(decode(href), origin); } catch { return null; }
    if (url.origin !== origin.origin) return null;
    url.hash = '';
    url.search = '';
    return url.href;
}

const inbound = new Map([...sitemapUrls].map(url => [url, new Set()]));
for (const [source, page] of pages) {
    for (const match of page.html.matchAll(/<a\b[^>]*href=["']([^"']+)["']/gi)) {
        const target = internal(match[1]);
        if (target && inbound.has(target) && target !== source) inbound.get(target).add(source);
    }
}
for (const [url, sources] of inbound) {
    if (url !== origin.href && sources.size === 0) report('defect', `${url}: orphaned sitemap page`);
    const pathname = new URL(url).pathname;
    for (const rule of config.internalSourceRules || []) {
        if (new RegExp(rule.pathPattern).test(pathname) && sources.size < Number(rule.minimum)) {
            report('defect', `${url}: ${sources.size} internal source page(s); expected ${rule.minimum}`);
        }
    }
}

const summary = { contractVersion: config.contractVersion, pages: entries.length, defects, infrastructure };
if (JSON_OUTPUT) console.log(JSON.stringify(summary));
else console.log(`check-search: ${entries.length} sitemap pages, ${defects} defects, ${infrastructure} infrastructure failures`);
process.exit(infrastructure ? 2 : defects ? 1 : 0);
