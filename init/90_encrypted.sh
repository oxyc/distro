encrypted_remote="oxyfi@oxy.fi:/home/oxyfi/encrypted"
encrypted_local="${repo_dir}/caches/encrypted"

mkdir -p "$cache_dir"

e_header "Downloading encrypted files"
e_notify "Downloaded to: $encrypted_local" \
  $(scp -r "$encrypted_remote" "$encrypted_local")

for src in $(find "$encrypted_local" -name '*.gpg' -type f); do
  local file_path=$(echo "$src" | awk -F "$encrypted_local/" '{ print $2 }')
  local dest=$HOME/$file_path
  e_arrow "Decrypting to $dest"
  e_notify "Decrypted" $(gpg -d $src --output $dest)
done

rm -rf $encrypted_local

unset encrypted_remote encrypted_local src
