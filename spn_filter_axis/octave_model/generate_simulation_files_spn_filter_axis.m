function generate_simulation_files_spn_filter_axis(varargin)

  p = inputParser();
  
  p.addParamValue('rtl_sim_location', '../../rtlsimlib/isp/spn_filter_axis/input_data');
  p.addParamValue('input_name'    , 'input_axis_image_vectors'); 
  p.addParamValue('output_name'   , 'expected_output_vectors'); 
  p.addParamValue('DEBUG'   , 0); 
  
  p.addParamValue('G_PIXEL_DEPTH', 4);
  p.addParamValue('G_IMG_WIDTH', 5);
  p.addParamValue('G_IMG_HEIGHT', 5);
  p.addParamValue('num_of_frames', 2);
  p.addParamValue('iv_s_axis_tdata'  , []); %zeros(G_IMG_WIDTH, G_IMG_WIDTH)
  p.addParamValue('il_s_axis_tlast'  ,0);
  p.addParamValue('il_s_axis_tvalid'  ,0);
  p.addParamValue('il_m_axis_tready'  ,0);
  
  p.parse(varargin{:});  
  
  rtl_sim_location    = p.Results.rtl_sim_location;
  input_name          = p.Results.input_name;
  output_name         = p.Results.output_name;
  DEBUG               = p.Results.DEBUG;
  
  G_PIXEL_DEPTH       = p.Results.G_PIXEL_DEPTH;
  G_IMG_WIDTH         = p.Results.G_IMG_WIDTH;
  G_IMG_HEIGHT        = p.Results.G_IMG_HEIGHT;
  num_of_frames       = p.Results.num_of_frames;
  iv_s_axis_tdata     = p.Results.iv_s_axis_tdata;
  il_s_axis_tlast     = p.Results.il_s_axis_tlast;
  il_s_axis_tvalid    = p.Results.il_s_axis_tvalid;
  il_m_axis_tready    = p.Results.il_m_axis_tready;
  
  iv_s_axis_tdata = uint16(randi([0, (2^(G_PIXEL_DEPTH) -1)], [G_IMG_HEIGHT, G_IMG_WIDTH, num_of_frames])); 
  %imwrite(iv_s_axis_tdata, 'input_data/rand_axis_img.png');
  
  %----------------------------------------------------------------------------
  % 
  %---------------------------------------------------------------------------- 
  for ff=1:num_of_frames
  
  [ov_image(:,:,ff)] = sim_spn_filter_axis(...
      'DEBUG'                       , DEBUG, ...
      'iv_s_axis_tdata'             , iv_s_axis_tdata(:,:,ff), ...
      'G_PIXEL_DEPTH'               , G_PIXEL_DEPTH, ...
      'G_IMG_WIDTH'                 , G_IMG_WIDTH, ...
      'G_IMG_HEIGHT'                , G_IMG_HEIGHT
      );
      
  dil_image(:,:,ff) = crossfilt(iv_s_axis_tdata(:,:,ff));   
  endfor
  %----------------------------------------------------------------------------
  % save to text the output file as the 
  %----------------------------------------------------------------------------
  fileIDout = fopen(sprintf('%s/%s.txt', rtl_sim_location, output_name),'w');
  
  for ff=1:num_of_frames
  for r = 1:G_IMG_HEIGHT
    for c = 1:G_IMG_WIDTH
      fprintf(fileIDout, '%s\n', dec2bin(ov_image(r, c, ff),G_PIXEL_DEPTH));  
    endfor
  endfor
  endfor
  fclose(fileIDout);
  
  %----------------------------------------------------------------------------
  % save to text input file
  %----------------------------------------------------------------------------
  
  fileID = fopen(sprintf('%s/%s.txt', rtl_sim_location, input_name),'w');
  
  % il_s_axis_tvalid  il_m_axis_tready il_s_axis_tlast iv_s_axis_tdata
  il_s_axis_tvalid = 1;
  il_m_axis_tready = 1;
  
  for ff=1:num_of_frames
  for r = 1:G_IMG_HEIGHT
    for c = 1:G_IMG_WIDTH
      if (r == G_IMG_HEIGHT && c == G_IMG_WIDTH)
        il_s_axis_tlast = 1; 
      else
        il_s_axis_tlast = 0;
      endif
    fprintf(fileID, '%d %d %d %s\n', il_s_axis_tvalid, il_m_axis_tready, il_s_axis_tlast, dec2bin(iv_s_axis_tdata(r,c,ff),G_PIXEL_DEPTH));  
    endfor
  endfor
  endfor
  fprintf(fileID, '%d %d %d %s\n', 0, 0, 0, dec2bin(0,G_PIXEL_DEPTH));  % closing with a 0 state
  
  fclose(fileID);
  
  disp(strftime ("%r (%Z) %A %e %B %Y \n", localtime (time ())));
  disp(['end of the file generation for the image ', num2str(G_IMG_WIDTH), ' x ' , num2str(G_IMG_HEIGHT)  ]);
  
end