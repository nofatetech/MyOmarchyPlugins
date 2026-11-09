<?php
// Kids Workbench: this Adminer only listens on 127.0.0.1, and the kids' SQLite files have
// no password, so allow an empty password (Adminer refuses that by default).
return new class extends \Adminer\Plugin {
	public function login($login, $password) {
		return true;
	}
};
