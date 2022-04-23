# Set up environment.  Sourced on login.

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Arch linux packages (/etc/profile.d/*.sh) use it
# We do not want these (perl, etc) in PATH
append_path()
{
	:
}

# Source /etc/profile.d/*.sh files
if [ -d /etc/profile.d ]; then
	for profile in /etc/profile.d/*.sh; do
		if [ -f "$profile" ] && [ -r "$profile" ]; then
			. "$profile"
		fi
	done
	unset profile
fi
