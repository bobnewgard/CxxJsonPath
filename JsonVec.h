/*
 *  Copyright 2020 Robert Newgard
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

#ifndef _JSON_VEC_H_
    #define _JSON_VEC_H_

    #include <string>
    #include <memory>
    #include <iomanip>
    #include <sstream>
    #include <vector>
    #include <array>
    #include <cstdio>

    #include <Msg.h>
    #include <JsonToken.h>

    namespace JsonParse
    {
        class JsonVecErr
        {
            public:
            std::string err_msg;

            JsonVecErr(std::string);
            ~JsonVecErr(void);

            std::string get_msg(void);
        };

        class JsonVec
        {
            private:
            std::unique_ptr<Messages::Msg>    msg;
            std::unique_ptr<JsonPath::Tokens> vec;
            std::string                       str;

            public:
            JsonVec(const std::string&, const std::string&);
            JsonVec(const std::string&);
            ~JsonVec(void);

            void dump_vec(void);
            void set_obj_bgn(void);
            void set_obj_end(void);
            void set_arr_bgn(void);
            void set_arr_end(void);
            void set_obj_key(char*);
            void set_elem_nul(void);
            void set_elem_tru(void);
            void set_elem_fal(void);
            void set_elem_str(char*);
            void set_elem_num(char*);

            JsonPath::Tokens & get_tokens(void);
        };

        extern "C"
        {
            #include "JsonVec_y.h"
        }
    }
#endif
