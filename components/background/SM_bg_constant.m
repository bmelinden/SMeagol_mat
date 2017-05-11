% IMBG=SM_bg_constant(t,bgOpt,cameraOpt)
% 
% Generate noisy background using Poisson noise with average value
% opt.background.photons_per_pixel counts per pixel, size and EMCCD noise
% according to cameraOpt.
%
% input
% t         : Start of frame for which background is to be generated  (not
%             used here). 
% optBG*    : background options struct (opt.background in Palantir).
%             Fields: 
%             optBG.photons_per_pixel = average number of bakground photons
%             per pixel 
% cameraOpt*: Palantir camera options struct (opt.camera), to pass
%             information about the image size and camera noise parameters.
%             
% * Only needed at first call, or when changing options. Otherwise, old
% values are remembered. 
%
% output
% 1) IMBG   : with no input arguments, a default bgOpt struct is returned.
% 2) IMBG   : with at least the t input parameter, a noisy background image
%             is generated, each pixel count having a Poissin photon
%             distribution with mean value bgOpt.photons_per_pixel, plus the
%             appropriate EMCCD noise and offset.

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SM_bg_constant.m, background model in the SMeagol package
% ========================================================================= 
% Copyright (C) 2015 Martin Lindén and Johan Elf
% 
% E-mail: bmelinden@gmail.com, johan.elf@gmail.com
% =========================================================================
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.  This program is distributed in the hope that it will
% be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
% the GNU General Public License for more details.
% 
% Additional permission under GNU GPL version 3 section 7
%  
% If you modify this Program, or any covered work, by linking or
% combining it with Matlab or any Matlab toolbox, the licensors of this
% Program grant you additional permission to convey the resulting work.
% 
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%% start of actual code
function IMBG=SM_bg_constant(~,bgOpt,cameraOpt)

persistent meanBackgroundCounts alpha sigmaReadout IMoffset

if(nargin==0) % no input arguments, return default opt struct
    IMBG=struct('photons_per_pixel',1); % default: on average one photon background per pixel and frame
    return
elseif(nargin>1) % then settings are to be updated
    meanBackgroundCounts=bgOpt.photons_per_pixel*ones(cameraOpt.yrange_px,cameraOpt.xrange_px); % x-ccordinates are columns
    alpha=cameraOpt.alpha;
    sigmaReadout=cameraOpt.sigmaReadout;
    IMoffset=cameraOpt.offset;
end

% generate the shotnoise background
IMBG=poissrnd(meanBackgroundCounts);

% add EMCCD noise, readout noise, and offset
IMBG=round(gamrnd(IMBG,1/alpha))...           % EMCCD gain
    +round(sigmaReadout*randn(size(IMBG)))... % readout noise
    +IMoffset;                                  % camera offset


