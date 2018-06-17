# This file is part of ssh-python.
# Copyright (C) 2017-2018 Panos Kittenis
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, version 2.1.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

from cpython.version cimport PY_MAJOR_VERSION

from c_ssh cimport ssh_error_types_e, ssh_get_error

from exceptions import RequestDenied, FatalError, OtherError


ENCODING='utf-8'


cdef bytes to_bytes(_str):
    if isinstance(_str, bytes):
        return _str
    elif isinstance(_str, unicode):
        return _str.encode(ENCODING)
    return _str


cdef object to_str(char *c_str):
    _len = len(c_str)
    if PY_MAJOR_VERSION < 3:
        return c_str[:_len]
    return c_str[:_len].decode(ENCODING)


cdef object to_str_len(char *c_str, int length):
    if PY_MAJOR_VERSION < 3:
        return c_str[:length]
    return c_str[:length].decode(ENCODING)


cdef int handle_error_codes(int errcode, void *caller) except -1:
    if errcode == ssh_error_types_e.SSH_NO_ERROR:
        return 0
    elif errcode == ssh_error_types_e.SSH_REQUEST_DENIED:
        raise RequestDenied(ssh_get_error(caller))
    elif errcode == ssh_error_types_e.SSH_FATAL:
        raise FatalError(ssh_get_error(caller))
    else:
        if errcode < 0:
            raise OtherError(ssh_get_error(caller))
        return errcode