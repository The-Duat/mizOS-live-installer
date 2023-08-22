#include <stdio.h>

int main(int argc, char **argv) 
{
	char bakname[100];
	char newname[100];
	char comment[100];
	char uncomment[100];
	if ( argv[1] == "locale" ) {
		bakname = "/etc/locale.bak";
		newname = "/etc/locale.gen";
		comment = "#en_US.UTF-8 UTF-8\n";
		uncommt = "en_US.UTF-8 UTF-8\n";
	} else if ( argv[1] == "sudo" ) {
		bakname = "/etc/sudo.bak";
		newname = "/etc/sudoers";
		comment = "# %wheel ALL=(ALL:ALL) ALL\n";
		uncommt = "%wheel ALL=(ALL:ALL) ALL\n"
	}
	rename("/etc/locale.gen", "/etc/locale.bak");
	FILE* bak = fopen(bakname, "r");
	FILE* new = fopen(newname, "w");

	char line[100];

	while fgets(line, sizeof(line), bak) {
		if (line == comment) {
			fputs(uncommt, new);
		} else {
			fputs(line, new);
		}
	}
}
