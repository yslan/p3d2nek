## modified by ylan, 10/27/23
## Copyright (C) 2016-2018 Mike Miller
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

function str = datetime (varargin)

   v = clock ();
   w.Year =   v(:,1);
   w.Month =  v(:,2);
   w.Day =    v(:,3);
   w.Hour =   v(:,4);
   w.Minute = v(:,5);
   w.Second = v(:,6);
   w.Format = "default";
   w.TimeZone = "";
   v = [w.Year, w.Month, w.Day, w.Hour, w.Minute, w.Second];

   if (ischar (varargin{3})); 
      fmt = varargin{3}; 
      str = datestr(v,fmt);
   else
      str = datestr(v);
   end

