chapel_binary_download() {
  binary="chapel-1.15.0.tar.gz"
  rm $binary 2> /dev/null
  echo "Downloading binary $binary"
  wget https://github.com/chapel-lang/chapel/releases/download/1.15.0/$binary
}

chapel_binary_expand() {
  binary="chapel-1.15.0.tar.gz"
  echo "Expanding binary $binary"
  tar xzf $binary
}

chapel_set_env() {
  chapel_folder_cd
  if [[ -z $chapel_hosts ]]; then
    chapel_hosts="tripio trauco caleuche"
    # chapel_hosts="hercules tripio titan caleuche trauco makemake";
  fi
  if [[ -z $CHPL_HOME ]]; then
    export CHPL_HOME=$(pwd | sed 's/ /\\ /g')
    source util/quickstart/setchplenv.bash
  fi
  if [[ -z $chapel_comm ]]; then
    # chapel_comm=ibv
    chapel_comm=gasnet
  fi
  export CHPL_COMM=$chapel_comm
  export GASNET_SPAWNFN=S # Use SSH
  export GASNET_SSH_SERVERS=$chapel_hosts
  cd ..
}

chapel_folder_cd() {
  cd -- "$(dirname "$BASH_SOURCE")"
  cd chapel-1.15.0
}

chapel_binary_build() {
  echo 'Building'
  chapel_folder_cd
  make
  cd ..
}

chapel_binary_clean() {(
    echo 'Cleaning'
    chapel_folder_cd
    make clean
    cd ..
)}

chapel_binary_clear() {
  chapel_binary_clean
  chapel_folder_cd
  cd ..
  rm -rf chapel-1.15.0
}

chapel_full_install() {
  chapel_binary_clear
  chapel_binary_download
  chapel_binary_expand
  chapel_set_env
  chapel_binary_build
}

chapel_test() {
  test="test.chpl"
  echo "Building and running $test"
  chapel_br $test $@
}

chapel_b() {
  # Build
  chpl -o $1.out $1
}

chapel_br() {
  # Build and run
  params_full=($@)
  if [[ -z $2 ]]; then params_full=($1 '-nl' '3'); fi
  params="${params_full[@]:1}"
  chapel_b $1
  ./$1.out $params
}
