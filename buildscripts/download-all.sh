set -euo pipefail

chmod +x $BUILDSCRIPTS_DIR/download-sdk.sh
chmod +x $BUILDSCRIPTS_DIR/download.sh

$BUILDSCRIPTS_DIR/download-sdk.sh &
$BUILDSCRIPTS_DIR/download.sh &

wait
