#charset "us-ascii"
//
// syslog.t
//
//	Simple syslog(3)-ish logging for TADS3 debugging.
//
//	The project must be compiled with the -D SYSLOG flag to enable logging.
//
//
// BASIC USAGE:
//
//		// Define a class using Syslog
//		class MyClass: Thing, Syslog
//			syslogID = 'LoggingPrefix'
//			log() {
//				_debug('this space intentionally left blank');
//			}
//		;
//
//		local obj = new MyClass();
//		obj.log();
//
//	When compiled with -D SYSLOG, this will produce:
//
//		LoggingPrefix: this space intentionally left blank
//
//	When compiled without -D SYSLOG, nothing will be output.
//
//	If no syslogID property is defined on the logging object, the
//	object's object ID will be used instead (this will look something
//	like "object#9844", which is just toString(self) on the object).
//
//
// LOGGING FLAGS
//
//	Each logged message can include an optional flag that can be used
//	to enable/disable logging of specific kinds of messages.
//
//		class MyOtherClass: Thing, Syslog
//			syslogID = 'FlagTest'
//			log() {
//				_debug('testing 123', 'testflag');
//			}
//		;
//
//		local obj = new MyOtherClass();
//
//		// This will not produce any output
//		obj.log();
//
//		syslog.enable('testflag');
//
//		// Now it will output "FlagTest: testing 123"
//		obj.log();
//
//		syslog.disable('testflag');
//
//		// No output again
//		obj.log();
//
//
// ADDITIONAL PREPROCESSOR FLAGS
//
//	-D SYSLOG_OBJ
//		If compiled with this flag, output will include the object
//		ID in addition to any syslogID defined for the class/instance.
//		This is mostly useful if you're defining syslogIDs for
//		classes, but want to be able to distinguish between individual
//		instances in the logging output.
//		
//
#include <adv3.h>
#include <en_us.h>

// Global singleton.
// This is included whether or not we're compiled with -D SYSLOG
// so stuff that enabled/disables logging doesn't have to be stuffed
// in preprocessor flags.
syslog: object
	_flag = perInstance(new LookupTable)	// hash table for our "flags"

	// Flag handling methods.
	enable(f) { _flag[f] = true; }			// set flag
	disable(f) { _flag[f] = nil; }			// clear flag
	check(f) { return(_flag[f] == true); }		// check if flag is set

	// Main debugging output method.
	debug(svc, msg, flg?, obj?) {
		// If a flag is given, make sure it's currently set.
		if((flg != nil) && (check(flg) != true))
			return;

		// See if we should log the object ID in addition to the
		// "service" ID.
		aioSay('\n<<svc>>: <<msg>>\n ');
	}

	// Like the debug method, only we output no matter what.
	error(svc, msg, obj?) { aioSay('\n<<svc>>: <<msg>>\n '); }
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

// If we're compiled with -D SYSLOG_OBJ, add the object ID to the syslogID
// if that's not what we're using already.
#ifdef SYSLOG_OBJ
modify Syslog
	getSyslogID() { return(syslogID ? '<<toString(self)>>: <<syslogID>>'
		: toString(self)); }
;
#endif // SYSLOG_OBJ

#endif // SYSLOG
