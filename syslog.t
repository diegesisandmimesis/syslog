#charset "us-ascii"
//
// syslog.t
//
#include <adv3.h>
#include <en_us.h>

// Global singleton.
// This is included whether or not we're compiled with -D SYSLOG
// so stuff that enabled/disables logging doesn't have to be stuffed
// in preprocessor flags.
syslog: object
	_flag = perInstance(new LookupTable)
	_pid = 0

	enable(f) { _flag[f] = true; }
	disable(f) { _flag[f] = nil; }
	check(f) { return(_flag[f] == true); }

	getPID() { return(_pid += 1); }

	debug(svc, msg, flg?, obj?) {
		if((flg != nil) && (check(flg) != true))
			return;
		if(obj != nil)
			aioSay('\n<<obj>>: <<svc>>: <<msg>>\n ');
		else
			aioSay('\n<<svc>>: <<msg>>\n ');
	}

	error(svc, msg) { aioSay('\n<<svc>>: <<msg>>\n '); }
;

// Stub object.
class Syslog: object
	syslogID = nil
	_debug(msg, flg?) {}
	_error(msg) {}
;


// The meat of the module lives in a big preprocessor conditional, so
// it doesn't do anything unless we're compiled with -D SYSLOG.
#ifdef SYSLOG

// Module ID for the library
syslogModuleID: ModuleID {
        name = 'Syslog Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Modify the base Syslog class so the debugging methods actually
// do something.
modify Syslog
	getSyslogID() { return(syslogID ? syslogID : toString(self)); }
	_debug(msg, flg?) { syslog.debug(getSyslogID(), msg, flg); }
	_error(msg) { syslog.error(getSyslogID(), msg); }
;

#ifdef SYSLOG_OBJ
modify Syslog
	getSyslogID() { return(syslogID ? '<<toString(self)>>: <<syslogID>>'
		: toString(self)); }
;
#endif // SYSLOG_OBJ

#endif // SYSLOG
