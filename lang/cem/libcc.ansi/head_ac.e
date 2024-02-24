#
/*
 * (c) copyright 1983 by the Vrije Universiteit, Amsterdam, The Netherlands.
 *
 *          This product is part of the Amsterdam Compiler Kit.
 *
 * Permission to use, sell, duplicate or disclose this software must be
 * obtained in writing. Requests for such permissions may be sent to
 *
 *      Dr. Andrew S. Tanenbaum
 *      Wiskundig Seminarium
 *      Vrije Universiteit
 *      Postbox 7161
 *      1007 MC Amsterdam
 *      The Netherlands
 *
 */

 mes 2,_EM_WSIZE,_EM_PSIZE

 exa environ
 exa _end

 exp $_m_a_i_n
 pro $_m_a_i_n,0
 loc 1336	; EIOVFL | EIUND | ECONV | EFOVFL | EFUNFL
 sim            ; ignored
 lal _EM_WSIZE+_EM_PSIZE
 loi _EM_PSIZE
 lae environ
 sti _EM_PSIZE
 lal _EM_WSIZE+_EM_PSIZE
 loi _EM_PSIZE
 lal _EM_WSIZE
 loi _EM_PSIZE
 lal 0
 loi _EM_WSIZE
 cal $main
 asp _EM_WSIZE+_EM_PSIZE+_EM_PSIZE
 lfr _EM_WSIZE
 cal $exit
 end
