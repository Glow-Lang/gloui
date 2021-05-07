(display "foo\n")


(##inline-host-declaration "console.warn('FFFFOOOOOOOOOOOOOOOOOOOBBBBBBBAAARR')")
(##inline-host-declaration
 #<<EOF

 @old_module_register@ = globalThis.@old_module_register@ || @module_register@
 @old_program_start@ = globalThis.@old_program_start@ || @program_start@

 @is_program_started@ = function () { !!_g[_i("##program-descr").r] }

@new_modules@ = []
 @module_register@ = function(module_descr)

{

  @new_modules@.push(module_descr[4])

  return @old_module_register@(module_descr)
 }


 @program_start@ = () => {
   @old_program_start@();
   @new_modules@.map(i => @procedure2host@(i)())
 };

EOF
)


;; (load "bar.scm")

(##inline-host-statement "console.warn('FFFFOOOOOOOOOOOOOOOOOOOBBBBBBBAAARR')")
