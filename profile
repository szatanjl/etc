# Set up environment.  Sourced on login.

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Source /etc/profile.d/*.sh files
if [ -d /etc/profile.d ]; then
	for profile in /etc/profile.d/*.sh; do
		if [ -f "$profile" ] && [ -r "$profile" ]; then
			. "$profile"
		fi
	done
	unset profile
fi
