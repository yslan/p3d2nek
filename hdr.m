
addpath('utils')
addpath('reader_p3d')
addpath('writer_nek')
addpath('plotting')

% Octave
if(exist('datetime')~=2);
  disp('WARN: Add legacy support for datetime');
  addpath('legacy/datetime');
end
%if(exist('histcounts')~=2);
%  disp('WARN: Add legacy support for datetime');
%  addpath('legacy/histcounts');
%end
