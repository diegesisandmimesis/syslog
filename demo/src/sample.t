#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a noninteractive demo of the syslog logging functions.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "syslog.h"

class Foo: Syslog;
class Bar: Syslog syslogID = 'bar';
class FlagTest: Syslog syslogID = 'flagTest';
class ServiceTest: Syslog syslogID = 'serviceID' syslogFlag = 'serviceFlag';

class Baz: object syslogID = 'baz';


versionInfo: GameID;
gameMain: GameMainDef
	disclaimer() {
#ifdef SYSLOG
		"<b>LOGGING ENABLED</b>\n ";
		"<.p>Demo compiled with <b>-D SYSLOG</b>\n ";
		"<.p>Demo compiled with <b>-D SYSLOG_OBJ</b> (object IDs
			will be added)\n ";
#else // SYSLOG
		"<b>LOGGING DISABLED</b>\n ";
		"<.p>Demo compiled without <b>-D SYSLOG</b>\n ";
#endif // SYSLOG
		"<.p> ";
	}

	newGame() {
		disclaimer();

		logBasic();
		logFlags();
		logService();
		logAll();
	}

	logBasic() {
		local obj0, obj1;

		"<.p><b>BASIC LOGGING</b>\n ";
		"<.p> ";
		obj0 = new Foo();
		obj0._debug('the ID for this message should be an object
			reference.');

		obj1 = new Bar();
		obj1._debug('the ID for this message should be <q>bar</q>');
	}

	logFlags() {
		local obj0, obj1;

		"<.p><b>LOGGING FLAGS</b>\n ";
		"<.p> ";
		syslog.enable('flagtest1');
		syslog.enable('flagtest2');

		obj0 = new FlagTest();
		obj1 = new FlagTest();

		obj0._debug('this message should be displayed', 'flagtest1');
		obj1._debug('this message should also be displayed',
			'flagtest2');

		syslog.disable('flagtest2');
		obj0._debug('this message should be displayed again',
			'flagtest1');
		obj1._debug('this message should not be displayed',
			'flagtest2');
		syslog.disable('flagtest1');
	}

	logService() {
		local obj;

		"<.p><b>SERVICE FLAGS</b>\n ";
		"<.p> ";
		obj = new ServiceTest();
		obj._syslog('this message should not be displayed');
		syslog.enable('serviceFlag');
		obj._syslog('this message should be displayed');
	}

	logAll() {
#ifdef SYSLOG_ALL
		local obj;

		"<.p><b>SYSLOG ALL</b>\n ";
		"<.p> ";
		obj = new Baz();
		obj._debug('this is a non-Syslog instance logging');
#else // SYSLOG_ALL
		"<.p><b>SYSLOG ALL NOT ENABLED</b>\n ";
		"<.p> ";
		"Recompile with -D SYSLOG_ALL to enable.\n ";
#endif // SYSLOG_ALL
	}
;


// Test
// Test 2
