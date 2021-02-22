.PHONT: download_dependencies
download_dependencies:
	@echo "Downloading MaxMind GeoIP database"
	@echo "..."

.PHONY: beacon_fmt
beacon_fmt:
	gofmt -d -w -s -e ./beacon
