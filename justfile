

rvm:
  ./bin/utils/restore_vm.sh



up:
  # docker compose up --build
  docker compose up --rm

gui:
  bootstrap.sh --tags gui