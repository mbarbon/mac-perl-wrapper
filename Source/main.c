/* main.c: PerlWrapper main source file
 * ------------------------------------------------------------------------
 * Starts a Perl interpreter, sets a few variables and library paths.
 * Executes 'start.pl'.
 * ------------------------------------------------------------------------
 * $Id: main.c 11 2004-10-17 22:19:26Z crenz $
 * Copyright (C) 2004 Christian Renz <crenz@web42.com>.
 * All rights reserved.
 */
 
#include <unistd.h>
#include <Carbon/Carbon.h>
#include <perlinterpreter.h>

int main(int argc, char* argv[]) {
	CFBundleRef mainBundle;
	CFURLRef myURL;
	FSRef fsref;
	char sPath[1024];
	char source[2200];

	perl_init();
	perl_exec("$PerlWrapper::Version = '0.1'");

	mainBundle = CFBundleGetMainBundle();

	// Store bundle path in perl variable
	myURL = CFBundleCopyBundleURL(mainBundle);
	if (!CFURLGetFSRef (myURL, &fsref)) {
		printf("[Wrapped Perl Application] Error getting FSRef\n");
		return 1;
	}
	FSRefMakePath(&fsref, (UInt8 *) &sPath, 1023);
	sprintf(source, "$PerlWrapper::BundlePath = '%s';", sPath);
	perl_exec(source);
	
	// Change path so dynamic libraries will be found
	chdir(sPath);

	// Store resources path in perl variable
	myURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
	if (!CFURLGetFSRef (myURL, &fsref)) {
		printf("[Wrapped Perl Application] Error getting FSRef\n");

		return 1;
	}
	FSRefMakePath(&fsref, (UInt8 *) &sPath, 1023);
	sprintf(source, "$PerlWrapper::ResourcesPath = '%s'", sPath);
	perl_exec(source);

	sprintf(source, 
        "use lib ('%s/Perl-Source', '%s/Perl-Libraries'); eval { require 'main.pl' }; $PerlWrapper::Error = $@; ",
	    sPath, sPath);	
	perl_exec(source);
	
	char *err = perl_getstring("PerlWrapper::Error");
	if (strlen(err) > 0) {
		SInt16 btnhit;
		Str255 caption;
		Str255 message;
		CopyCStringToPascal("Perl Error", caption);
		CopyCStringToPascal(err, message);
		printf("[Wrapped Perl Application] Perl Error:\n%s\n", err);
		OSErr r = StandardAlert(kAlertStopAlert,
			caption, message, NULL, &btnhit); 
	}
	
	perl_destroy();

	// todo: Get perl's return code
	return 0;
}

/* eof *******************************************************************/