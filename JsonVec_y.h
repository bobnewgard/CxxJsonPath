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

int  json_parse(void*, char*);
void c_set_obj_bgn(void*);
void c_set_obj_end(void*);
void c_set_arr_bgn(void*);
void c_set_arr_end(void*);
void c_set_obj_key(void*, char*);
void c_set_elem_nul(void*);
void c_set_elem_tru(void*);
void c_set_elem_fal(void*);
void c_set_elem_str(void*, char*);
void c_set_elem_num(void*, char*);
