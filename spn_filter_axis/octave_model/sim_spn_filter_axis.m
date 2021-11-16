%I = uint8(randi([0, 255], [20, 2^12])); 
%imwrite(I, 'input/E.png');

function [ ov_image] = sim_spn_filter_axis(varargin)

  p = inputParser();
  p.addParamValue('DEBUG'   , 0); 
  
  p.addParamValue('iv_s_axis_tdata'    , ones(12,12)); 
  p.addParamValue('G_PIXEL_DEPTH', 16);
  p.addParamValue('G_IMG_WIDTH', 16);
  p.addParamValue('G_IMG_HEIGHT', 8);
  %p.addParamValue('num_of_frames',  2);
  
  p.parse(varargin{:}); 
  
  DEBUG               = p.Results.DEBUG;
  G_PIXEL_DEPTH       = p.Results.G_PIXEL_DEPTH;
  G_IMG_WIDTH         = p.Results.G_IMG_WIDTH;
  G_IMG_HEIGHT        = p.Results.G_IMG_HEIGHT;
  iv_s_axis_tdata     = p.Results.iv_s_axis_tdata;
  
  %----------------------------------------------------------------------------
  % Calculation
  %----------------------------------------------------------------------------
  ov_image = zeros(G_IMG_HEIGHT, G_IMG_WIDTH);
  
  for r = 1:G_IMG_HEIGHT
    for c = 1:G_IMG_WIDTH
      
      if     (r == 1            && c ==1) % left top corner
        sortv = sort( [iv_s_axis_tdata(1,1), iv_s_axis_tdata(1,2), iv_s_axis_tdata(2,1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
         disp('1 - left top corner');
        endif
      elseif (r == 1            && (c >1 && c < G_IMG_WIDTH)) % top bar
        sortv = sort( [iv_s_axis_tdata(1,c-1), iv_s_axis_tdata(1,c), iv_s_axis_tdata(1,c+1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('2 - top bar');
        endif
      elseif (r == 1            && c == G_IMG_WIDTH) % right top corner
        sortv = sort( [iv_s_axis_tdata(1,G_IMG_WIDTH-1), iv_s_axis_tdata(1,G_IMG_WIDTH), iv_s_axis_tdata(2,G_IMG_WIDTH)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('3 - right top corner');
        endif
      elseif (c == 1            && (r > 1 && r < G_IMG_HEIGHT)) % left bar
        sortv = sort( [iv_s_axis_tdata(r-1,1), iv_s_axis_tdata(r,1), iv_s_axis_tdata(r+1,1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('4 - left bar');
        endif
      elseif (c == G_IMG_WIDTH  && (r > 1 && r < G_IMG_HEIGHT)) % right bar
        sortv = sort( [iv_s_axis_tdata(r-1,G_IMG_WIDTH), iv_s_axis_tdata(r,G_IMG_WIDTH), iv_s_axis_tdata(r+1,G_IMG_WIDTH)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('5 - right bar');
        endif
      elseif (r == G_IMG_HEIGHT && c == 1)% corner left bottom
        sortv = sort( [iv_s_axis_tdata(G_IMG_HEIGHT,1), iv_s_axis_tdata(G_IMG_HEIGHT,2), iv_s_axis_tdata(G_IMG_HEIGHT -1,1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('6 - corner left bot');
        endif
      elseif (r == G_IMG_HEIGHT && (c >1 && c < G_IMG_WIDTH)) % bottom bar
        sortv = sort( [iv_s_axis_tdata(G_IMG_HEIGHT,c-1), iv_s_axis_tdata(G_IMG_HEIGHT,c), iv_s_axis_tdata(G_IMG_HEIGHT , c+1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('7 - bottom bar');
        endif
      elseif (r == G_IMG_HEIGHT && c == G_IMG_WIDTH)% corner right bottom
        sortv = sort( [iv_s_axis_tdata(G_IMG_HEIGHT , G_IMG_WIDTH), iv_s_axis_tdata(G_IMG_HEIGHT -1, G_IMG_WIDTH), iv_s_axis_tdata(G_IMG_HEIGHT, G_IMG_WIDTH -1)] );
        ov_image(r,c) = sortv(2);
        if (DEBUG==1)
          disp('8 - corner right bottom');
        endif
      else % cross
        sortv = sort( [iv_s_axis_tdata(r-1,c), iv_s_axis_tdata(r,c), iv_s_axis_tdata(r+1,c), iv_s_axis_tdata(r,c-1), iv_s_axis_tdata(r,c +1) ] );
        ov_image(r,c) = sortv(3);
        if (DEBUG==1)
          disp('9 - middle');
        endif
      endif
    endfor
  endfor
  
 end