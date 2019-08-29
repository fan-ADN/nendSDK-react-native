#!/bin/sh

cd ..

npm run test:e2e:android
mv reports/report.xml reports/report_android.xml

# TODO: 同時に走らせるとテストがコケるので、必要な方だけ一先ず実行する
# npm run test:e2e:ios
# mv reports/report.xml reports/report_ios.xml
