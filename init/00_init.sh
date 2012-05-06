
# Installing this sudoers file makes life easier.
sudoers_file="sudoers-dotfiles"
sudoers_src="${repo_dir}/conf/ubuntu/${sudoers_file}"
sudoers_dest="/etc/sudoers.d/$sudoers_file"
if [[ ! -e "$sudoers_dest" || "$sudoers_dest" -ot "$sudoers_src" ]]; then
  e_header "Updating sudoers"
  visudo -cf "$sudoers_src" >/dev/null && {
    sudo cp "$sudoers_src" "$sudoers_dest" &&
    sudo chmod 0440 "$sudoers_dest"
  } >/dev/null 2>&1 &&
  echo "File $sudoers_dest updated." ||
  echo "Error updating $sudoers_dest file."
fi

# @todo
# hosts
# rc

unset sudoers_file sudoers_src sudoers_dest
