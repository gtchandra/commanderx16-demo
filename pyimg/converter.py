from PIL import Image
import numpy as np
import sys
print (sys.argv[1])

im=Image.open(sys.argv[1])
im2=im.resize((80,60), resample=Image.ANTIALIAS)
im3=im2.convert("P", palette=Image.ADAPTIVE, colors=256)
im3.save(sys.argv[1],"GIF")
palette=im3.getpalette()
pal_array=np.array(palette)
n_pal_array=pal_array.reshape(256,3)
p_arr=[]
counter=0
#not a great conversion algorythm...
for x in n_pal_array:
  p_arr.append((x[1]&240)+(x[2]>>4))
  p_arr.append(x[0]>>4)
  counter+=1
  #print("${:02x}".format((x[1]&240)+(x[2]>>4))+",${:02x}".format(x[0]>>4))
  #if (counter==64):
  #  break
  #print("${:02x}".format(x[1])+"${:02x}".format(x[2])+"${:02x}".format(x[0]))
np_arr=np.array(p_arr)
np_arr.astype('int8').tofile("palette.dat")

#image works
image_array=[]
for y in range(0,60):
  for x in range(0,80):
    image_array.append(im3.getpixel((x,y)))
n_image_array=np.array(image_array)
nn_image_array=n_image_array.reshape(60,80)

#image save
nn_image_array.astype('int8').tofile("image.dat")
