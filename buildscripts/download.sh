set -euo pipefail

chmod +x $BUILDSCRIPTS_DIR/download-sdk.sh
chmod +x $BUILDSCRIPTS_DIR/download-deps.sh

$BUILDSCRIPTS_DIR/download-sdk.sh &
$BUILDSCRIPTS_DIR/download-deps.sh &

wait
