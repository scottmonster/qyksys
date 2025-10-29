

TEST_PASS="./env/bootstrap_test.key"
SUDO_FILE="$TEST_PASS"
VAULT_FILE="$TEST_PASS"
VAULT_ID="bootstrap_test"


if [ ! -z "$_dev" ]; then
  unset SUDO_FILE
fi