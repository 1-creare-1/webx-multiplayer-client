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

local HOST = window.link
local URL
if HOST:find("localhost") then
    URL = "localhost.dev/"
else
    URL = "raymarch.dev/"
end

-- buss://raymarch.dev/play
for _, url in get("link", true) do
    url.set_href("buss://" .. url.get_href():gsub("#", URL))
end