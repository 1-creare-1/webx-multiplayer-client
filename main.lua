-- Debug Helpers
local outputLabel, errorLabel = get("output"), get("error")
function log(msg)
	outputLabel.set_content(tostring(msg) .. "\n" .. outputLabel.get_content())
end

function warn(msg)
	errorLabel.set_content(tostring(msg) .. "\n" .. errorLabel.get_content())
end

-- Hide silly seo optimization
get("seo").set_visible(false)

local u = window.link
log(u)
-- buss://raymarch.dev/play
for _, url in get("link", true) do
    log(url.get_href())
    url.set_href("buss://" .. url.get_href():gsub("#", "localhost.dev/"))
    log(url.get_href())
end