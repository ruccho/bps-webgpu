dxc -spirv -T cs_6_0 -E MetaPass BitonicPixelSorter.compute -Fo BitonicPixelSorter_MetaPass.spv
dxc -spirv -T cs_6_0 -E SortPass BitonicPixelSorter.compute -Fo BitonicPixelSorter_SortPass.spv

tint BitonicPixelSorter_MetaPass.spv -o BitonicPixelSorter_MetaPass.wgsl
tint BitonicPixelSorter_SortPass.spv -o BitonicPixelSorter_SortPass.wgsl