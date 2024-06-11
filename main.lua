local u = window.url
print(u)
for _, url in get("a", true) do
    print(url:get_href())
    url.set_href(url.get_href():gsub("#", "localhost.dev/"))
end