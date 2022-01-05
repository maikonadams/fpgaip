function generate_mosaic_image(varargin)
  
  p = inputParser();
  
  p.addParamValue('input_file_location'         , 'input/' ); %jpg
  p.addParamValue('input_image_file'            , 'kodim07.png'); 
  p.addParamValue('ISP_pixel_size'              ,    8);
  p.addParamValue('G_IMG_WIDTH', 768); %768
  p.addParamValue('G_IMG_HEIGHT',512); %512
  p.addParamValue('G_PIXEL_WIDTH', 8);
  p.addParamValue('num_of_frames', 1);
  
  p.addParamValue('save_location'               , '../rtl/input_data');
  p.addParamValue('save_input_image'            , 'input_image'); 
  p.addParamValue('save_expected_output'        , 'expected_output_image'); 
  
  p.parse(varargin{:}); 
  
  disp('----------Starting of Generating Files--------- ');
  
  input_file_location    = p.Results.input_file_location;
  input_image_file       = p.Results.input_image_file;
  ISP_pixel_size         = p.Results.ISP_pixel_size;
  G_IMG_WIDTH            = p.Results.G_IMG_WIDTH;
  G_IMG_HEIGHT           = p.Results.G_IMG_HEIGHT;
  G_PIXEL_WIDTH          = p.Results.G_PIXEL_WIDTH;
  num_of_frames          = p.Results.num_of_frames;
  
  save_location          = p.Results.save_location;
  save_input_image       = p.Results.save_input_image;
  save_expected_output   = p.Results.save_expected_output;
  
  gradientImg = 0; % replace the image for a gradient just to trainning purposes
  realImg     = 1;
  randImg     = 0;
  
  in_img = imread([input_file_location input_image_file]);
  pkg load image;
  if (G_IMG_WIDTH  != 768 || G_IMG_HEIGHT != 512) % original image size
    in_img = imresize (in_img, [G_IMG_HEIGHT G_IMG_WIDTH]);
  endif
  
  %mosaicedImage = RGB_to_mosaic(in_img);
  mosaicedImage2 = mosaic(in_img,'rggb');
  
  imwrite(in_img, 'input/kodim07.png');
  %imwrite(mosaicedImage, 'input/kodim07mosaiced.png');
  imwrite(mosaicedImage2, 'input/kodim07mosaiced2.png');
  
  
  if (gradientImg == 1)
    %grad = (G_IMG_WIDTH*G_IMG_HEIGHT -1):-1:0; %(7*7 -1):-1:0
    grad = zeros(G_IMG_HEIGHT, G_IMG_WIDTH);
    cont = 0;
    for r = 1:G_IMG_HEIGHT
      for c = 1:G_IMG_WIDTH
        grad(r,c) = cont ;
          if cont < (2^G_PIXEL_WIDTH -1 )
            cont = cont +1;
          else 
            cont = 0; 
          endif
      endfor
    endfor
     
    iv_image = grad;
    iv_image(1:5,1:5)
  elseif (randImg == 1)
    
  elseif (realImg == 1)
    mosaicedImage2(1:5,1:5)
    iv_image = mosaicedImage2;
  endif
  
  [rgb_image_after_demosaic] = sim_demosaicing_simple (...
    'iv_image'       , iv_image, ...
    'ISP_pixel_size' , ISP_pixel_size, ...
    'G_IMG_WIDTH'    , G_IMG_WIDTH, ...
    'G_IMG_HEIGHT'   , G_IMG_HEIGHT ...
  );
  
  %----------------------------------------------------------------------------
  % save mosaiced image to binary input file
  %----------------------------------------------------------------------------
  fileID = fopen(sprintf('%s/%s.bin', save_location, save_input_image),'w');
  fwrite(fileID, iv_image','uint8'); %,'ieee-be'
  fclose(fileID);
  
  %----------------------------------------------------------------------------
  % save mosaiced image to text input file
  %----------------------------------------------------------------------------
  fileIDInTxt = fopen(sprintf('%s/%s.txt', save_location, save_input_image),'w');
  last_pixel = 0;
  valid_pixel = 1; 
  for ff=1:num_of_frames
    for rr = 1:G_IMG_HEIGHT
      for cc = 1:G_IMG_WIDTH
        if (rr == G_IMG_HEIGHT && cc  == G_IMG_WIDTH)
          last_pixel = 1;  
        else
          last_pixel = 0;
        endif 
        fprintf(fileIDInTxt, '1 %d %s\n', last_pixel, dec2hex(iv_image(rr,cc,ff), 2)); %G_PIXEL_WIDTH
      endfor
    endfor
  endfor 
  fclose(fileIDInTxt); 
  
  %----------------------------------------------------------------------------
  % save demosaiced image to binary expected output file
  %----------------------------------------------------------------------------
  fileIDo    = fopen(sprintf('%s/%s.bin', save_location, save_expected_output),'w');
  fileIDoTxt = fopen(sprintf('%s/%s.txt', save_location, save_expected_output),'w');
  for r = 1:G_IMG_HEIGHT
    for c = 1:G_IMG_WIDTH
      fwrite(fileIDo, rgb_image_after_demosaic(r,c,1), 'uint8','ieee-be');
      fwrite(fileIDo, rgb_image_after_demosaic(r,c,2), 'uint8','ieee-be');
      fwrite(fileIDo, rgb_image_after_demosaic(r,c,3), 'uint8','ieee-be');
      
      fprintf(fileIDoTxt, ' %s',   dec2hex(rgb_image_after_demosaic(r,c,1), 2)); 
      fprintf(fileIDoTxt, ' %s',   dec2hex(rgb_image_after_demosaic(r,c,2), 2)); 
      fprintf(fileIDoTxt, ' %s\n', dec2hex(rgb_image_after_demosaic(r,c,3), 2)); 
    endfor  
  endfor
  fclose(fileIDo);
  fclose(fileIDoTxt);
  
  disp('----------End of Generated Files--------- ');
end

function mosaicedImage = RGB_to_mosaic(rgbImage)
  
[rows, columns, numberOfColorChannels] = size(rgbImage);
mosaicedImage = zeros(rows, columns, 'uint8');

for col = 1 : columns
  for row = 1 : rows
    if mod(col, 2) == 0 && mod(row, 2) == 0
      % Pick red value.
      mosaicedImage(row, col) = rgbImage(row, col, 1);
    elseif mod(col, 2) == 0 && mod(row, 2) == 1
      % Pick green value.
      mosaicedImage(row, col) = rgbImage(row, col, 2);
    elseif mod(col, 2) == 1 && mod(row, 2) == 0
      % Pick green value.
      mosaicedImage(row, col) = rgbImage(row, col, 2);
    elseif mod(col, 2) == 1 && mod(row, 2) == 1
      % Pick blue value.
      mosaicedImage(row, col) = rgbImage(row, col, 3);
    end
  end
end
   
end
