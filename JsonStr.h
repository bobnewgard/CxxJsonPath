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

/** \file  JsonStr.h
 *  \brief Declares the JsonStr class.
 */
#ifndef _JSON_STR_H_
    #define _JSON_STR_H_

    #include <string>
    #include <memory>
    #include <Msg.h>
    #include <JsonToken.h>

    namespace JsonPath
    {
        /** \class JsonStr
         *  \brief Methods to operate on a JSON representation.
         *
         *  The JsonStr methods are used to operate on an internal representation
         *  of a JSON string.
         */
        class JsonStr
        {
            private:
            std::unique_ptr<std::string> str;

            bool need_comma ( void );

            public:
            JsonStr(void);
            ~JsonStr(void);

            void add_obj_bgn ( void             );
            void add_obj_end ( void             );
            void add_arr_bgn ( void             );
            void add_arr_end ( void             );
            void add_key     ( std::string&     );
            void add_key     ( const char*      );
            void add_str     ( std::string&     );
            void add_str     ( const char*      );
            void add_num     ( std::string&     );
            void add_num     ( const char*      );
            void add_nul     ( void             );
            void add_tru     ( void             );
            void add_fal     ( void             );
            void add_val     ( Tokens&          );
            void add_val     ( std::string&     );
            void rem_all     ( void             );

            std::string & get_str(void) const;
        };
    }
#endif
