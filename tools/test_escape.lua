#!/usr/bin/env lua
-- Quick test for Component.escape
package.path = "src/?.lua;" .. package.path

-- Stub Theme module (escape doesn't need it)
package.preload["ui.Theme"] = function() return { resolve = function(v) return v end } end
package.preload["ui.Markup"] = function() return { expand = function(s) return s end } end

local Component = require("ui.Component")

-- Pure Cyrillic — unchanged
local r1 = Component.escape("Тест Кириллицы")
assert(r1 == "Тест Кириллицы", "FAIL cyrillic: " .. r1)

-- Decimal numeric entity — & preserved
local r2 = Component.escape("&#1058;&#1077;&#1089;&#1090;")
assert(r2 == "&#1058;&#1077;&#1089;&#1090;", "FAIL numeric entity: " .. r2)

-- Hex entity — & preserved
local r3 = Component.escape("&#x0422;")
assert(r3 == "&#x0422;", "FAIL hex entity: " .. r3)

-- Named entities — & preserved
local r4 = Component.escape("&amp;&lt;&gt;&quot;")
assert(r4 == "&amp;&lt;&gt;&quot;", "FAIL named entity: " .. r4)

-- Bare & — escaped
local r5 = Component.escape("A & B")
assert(r5 == "A &amp; B", "FAIL bare amp: " .. r5)

-- < > " — escaped
local r6 = Component.escape('<script>"hi"</script>')
assert(r6 == "&lt;script&gt;&quot;hi&quot;&lt;/script&gt;", "FAIL tags: " .. r6)

-- Apostrophe — NOT escaped
local r7 = Component.escape("it's fine")
assert(r7 == "it's fine", "FAIL apostrophe: " .. r7)

-- Mixed: Cyrillic + bare &
local r8 = Component.escape("Кот & Пёс")
assert(r8 == "Кот &amp; Пёс", "FAIL mixed: " .. r8)

-- & followed by non-entity chars
local r9 = Component.escape("&foo")
assert(r9 == "&amp;foo", "FAIL amp-no-semi: " .. r9)

print("ALL TESTS PASSED")
