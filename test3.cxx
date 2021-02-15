/*
 *  Copyright 2020-2021 Robert Newgard
 * 
 *  This file is part of CxxJsonPath.
 * 
 *  CxxJsonPath is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 * 
 *  CxxJsonPath is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 * 
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with CxxJsonPath.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <JsonStr.h>
#include <JsonFind.h>

using namespace std;
using namespace Messages;
using namespace Messages::Chars;
using namespace JsonPath;

bool debug_msg = false;

string str_p = R"(
    {
    	"build-ver-lib" : []
    }
)";

string str_c = R"(
    {
        "build-ver-lib" : [
	    {
		"work-dir" : "ver",
	    	"mod-name" : "uut1",
		"mod-srcs" : ["ver/uut_1_top.v", "ver/uut_1_bitp.v", "ver/uut_1_bytep.v"]
	    },
	    {
		"work-dir" : "ver",
	    	"mod-name" : "uut512",
		"mod-srcs" : ["ver/uut_512_top.v"]
	    }
	],
        "build-sysc-lib" : [
	    {
		"work-dir"  : "tb_1",
		"lib-name"  : "tb1",
		"lib-srcs"  : ["tb_1/tb.cxx"],
		"incl-dirs" : [
			"../SyscClk", "../SyscFCBus", "include", "../SyscMsg",
			"../SyscDrv", "../SyscJson", "ver/obj_dir", "."
		]
	    },
	    {
		"work-dir" : "tb_512",
		"lib-name" : "tb512",
		"lib-srcs" : ["tb_512/tb.cxx"],
		"incl-dirs" : [
			"../SyscClk", "../SyscFCBus", "include", "../SyscMsg",
			"../SyscDrv", "../SyscJson", "ver/obj_dir", "."
		]
	    },
	    {
		"work-dir" : "tb_1/test_0",
		"lib-name" : "test10",
		"lib-srcs" : ["tb_1/test_0/test.cxx, tb_1/test_0/sc_main.cxx"],
		"incl-dirs" : [
			"../SyscClk", "../SyscFCBus", "include", "../SyscMsg",
			"../SyscDrv", "../SyscJson", "ver/obj_dir", "tb_1", "."
		]
	    },
	    {
		"work-dir" : "tb_512/test_0",
		"lib-name" : "test5120",
		"lib-srcs" : ["tb_512/test_0/test.cxx, tb_512/test_0/sc_main.cxx"],
		"incl-dirs" : [
			"../SyscClk", "../SyscFCBus", "include", "../SyscMsg",
			"../SyscDrv", "../SyscJson", "ver/obj_dir", "tb_512", "."
		]
	    }
	],
	"build-exe" : [
	    {
		"work-dir"  : "tb_1/test_0",
		"exe-name"  : "tb_1/test_0/test10",
		"link-libs" : {
		    "syscmsg"  : "../SyscMsg",
		    "syscdrv"  : "../SyscDrv",
		    "syscjson" : "../SyscJson",
		    "tb1"      : "tb_1",
		    "uut1"     : "ver/obj_dir",
		    "test1"    : "."
		}
	    }
	],
	"dox" : [
	    {
		"work-dir"  : ".",
		"conf-fil"  : "dox.conf"
	    }
	]
    }

)";

int main(int argc, char * argv[])
{
    Msg                  msg("dejson:");
    Token                obsv;
    JsonStr              cstr;
    JsonStr              pstr;
    string               fstr;
    unique_ptr<JsonFind> json;

    if (debug_msg)
    {
        json = unique_ptr<JsonFind>(new JsonFind(msg.get_str_r_msgid() + "JsonFind:"));
    }
    else
    {
        json = unique_ptr<JsonFind>(new JsonFind());
    }

    cstr.add_val(str_c);
    pstr.add_val(str_p);

    try
    {
        json->set_search_context(cstr.get_str());
    }
    catch (JsonFindErr & err)
    {
        msg.cerr_err("catch() while parsing JSON search context");
        msg.cerr_err(err.get_msg());
        return 1;
    }

    try
    {
        json->set_search_path(pstr.get_str());
    }
    catch (JsonFindErr & err)
    {
        throw JsonFindErr("catch while parsing JSON search path");
        msg.cerr_err(err.get_msg());
        return 1;
    }
  
    json->find();

    json->get_context_string(fstr);

    cout << fstr << endl << flush;

    return 0;
}
