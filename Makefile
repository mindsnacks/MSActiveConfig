test:
	xctool -workspace MSActiveConfig.xcworkspace -scheme 'MSActiveConfigTests' -reporter pretty -sdk iphonesimulator clean test
