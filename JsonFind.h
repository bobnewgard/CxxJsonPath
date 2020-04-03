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

/** \file  JsonFind.h
 *  \brief Declares the JsonFind and JsonFindErr classes.
 */

#ifndef _JSON_H_
    #define _JSON_H_

    #include <string>
    #include <memory>
    #include <Msg.h>
    #include <JsonToken.h>

    namespace JsonPath
    {
        /** \class JsonFindErr
         *  \brief Exception class for JsonFind
         *
         *  This class is thrown by the
         *  JsonFind::set_search_context() and JsonFind::set_search_path()
         *  methods in the event of a JSON parsing error.
         *
         *  The err_msg string is set in the constructor and may be
         *  used to indicate why the exception was thrown.  It is
         *  accessed by the get_msg() method.
         */
        /** \var   JsonFindErr::err_msg
         *  \brief String data for exception message
         */
        class JsonFindErr
        {
            public:
            std::string err_msg;

            JsonFindErr(std::string);
            ~JsonFindErr(void);

            std::string get_msg(void);
        };

        /** \class JsonFind
         *  \brief Tokenized JSON, with methods for discovering and
         *         accessing values within the JSON structure.
         *
         *  <h2 class="mp">Methods</h2>
         *
         *  The set_search_context() method validates a JSON string and loads
         *  it into search context.
         *
         *  The set_search_path() method validates a JSON string and loads
         *  it into search path.
         *
         *  The find() method searches for the context token specified by the
         *  search path within the search context.
         *
         *  The get_context_string() returns a string representation of what
         *  is contained at the context token.
         */
        class JsonFind
        {
            private:
            std::unique_ptr<Messages::Msg> msg;
            std::unique_ptr<Tokens>        search_context;
            TokenI                         search_context_iter;
            std::unique_ptr<Tokens>        search_path;
            TokenI                         search_path_iter;
            std::unique_ptr<Token>         context_token;

            void           parse       ( Tokens&, std::string& );
            std::ptrdiff_t get_dist    ( void                  );
            void           set_context ( TokenI                );
            void           clr_context ( void                  );

            public:
            JsonFind(const std::string&);
            JsonFind(void);
            ~JsonFind(void);

            void      set_search_context   ( std::string& );
            void      set_search_path      ( std::string& );
            void      find                 ( void         );
            bool      context_is_none      ( void         );
            bool      context_is_obj_bgn   ( void         );
            bool      context_is_obj_end   ( void         );
            bool      context_is_arr_bgn   ( void         );
            bool      context_is_arr_end   ( void         );
            bool      context_is_key       ( void         );
            bool      context_is_str       ( void         );
            bool      context_is_num       ( void         );
            bool      context_is_nul       ( void         );
            bool      context_is_tru       ( void         );
            bool      context_is_fal       ( void         );
            void      get_context_string   ( std::string& );
        };
    }
#endif
