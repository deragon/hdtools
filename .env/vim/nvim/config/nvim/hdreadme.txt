Create a symlink in "${HOME}/config/nvim".

ln -s \
 "${HDVIM}/nvim/config/nvim" \
 "${HOME}/config/nvim"

Attempting to get LazyVim to fetch files directly from
"${HDVIM}/nvim/config/nvim" failed in 2025-05.  Its just simpler to setup a
symlink.
