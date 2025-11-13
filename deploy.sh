# Abort if `flutter test`` fails.
set -e

echo Running tests...
flutter test

echo Building...
flutter build appbundle --target-platform android-arm,android-arm64

echo Pretending to deploy...
sleep 5s
# cd android
# fastlane deploy
# cd ..

echo Done!
