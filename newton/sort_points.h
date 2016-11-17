.NOLIST      ; turn off listing
.386

EXTRN sort_points_proc : Near32
EXTRN print_points_proc : Near32

print_points	   MACRO points_array, num_points, xtra

                   IFB <points_array>
                      .ERR <missing "points_array_addr" operand in compare_floats>
                   ELSEIFB <num_points>
                      .ERR <missing "num_points" operand in compare_floats>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in compare_floats>
                   ELSE

                         push ebx
                            lea ebx, points_array
                            push ebx
                            push num_points
                            call print_points_proc
                         pop ebx

                   ENDIF

		ENDM

sort_points	   MACRO points_array, x_comp, tol, num_points, xtra

                   IFB <points_array>
                      .ERR <missing "points_array_addr" operand in compare_floats>
                   ELSEIFB <x_comp>
                      .ERR <missing "x_comp" operand in compare_floats>
                   ELSEIFB <tol>
                      .ERR <missing "tol" operand in compare_floats>
                   ELSEIFB <num_points>
                      .ERR <missing "num_points" operand in compare_floats>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in compare_floats>
                   ELSE

                         push ebx
                            lea ebx, points_array
                            push ebx
                            push x_comp
                            push tol
                            push num_points
                            call sort_points_proc
                         pop ebx

                   ENDIF

		ENDM

.NOLISTMACRO ; suppress macro expansion listings
.LIST        ; begin listing