/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2010, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(sics_system,
	  [ environ/2,			% ?Name, ?Value

	    exec/3,			% +Command, -Streams, -PID
	    wait/2,			% +PID, -Status
	    pid/1,			% -PID

	    sleep/1,			% +Seconds

	    shell/0,
	    shell/1,			% +Command
	    shell/2,			% +Command, -Status

	    system/0,
	    system/1,			% +Command
	    system/2,			% +Command, -Status

	    popen/3,			% +Command, +Mode, -Stream

	    working_directory/2,	% -Old, +New
	    make_directory/1,		% +DirName
	    file_exists/1,		% +FileName
	    delete_file/1,		% +FileName
	    rename_file/2,		% +Old, +New
	    mkstemp/2,			% +Template, -FileName
	    tmpnam/1			% -FileName
	  ]).
:- use_module(library(process)).

/** <module> SICStus-3 library system


@tbd	This library is incomplete
*/

%%	environ(?Name, ?Value) is nondet.
%
%	True if Value an atom associated   with the environment variable
%	Name.
%
%	@tbd	Mode -Name is not supported

environ(Name, Value) :-
	getenv(Name, Value).


		 /*******************************
		 *	      PROCESSES		*
		 *******************************/

%%	exec(+Command, +Streams, -PID)
%
%	SICStus 3 compatible implementation of  exec/3   on  top  of the
%	SICStus 4 compatible process_create/3.

exec(Command, Streams, PID) :-
	Streams = [In, Out, Error],
	shell(Shell, Command, Argv),
	process_create(Shell, Argv,
		       [ stdin(In),
			 stdout(Out),
			 stderr(Error),
			 process(PID)
		       ]).

shell('cmd.exe', Command, ['/C', Command]) :-
	current_prolog_flag(windows, true), !.
shell('/bin/sh', Command, ['-c', Command]).

%%	wait(+PID, -Status)
%
%	Wait for processes created using exec/3.
%
%	@see exec/3

wait(PID, Status) :-
	process_wait(PID, Status).

%%	pid(-PID)
%
%	Process ID of the current process.
%
%	@compat sicstus.

pid(PID) :-
	current_prolog_flag(pid, PID).

%%	system.
%%	system(+Command).
%%	system(+Command, -Status).
%
%	Synomyms for shell/0, shell/1 and shell/2.
%
%	@compat sicstus.

system :- shell.
system(Command) :- shell(Command).
system(Command, Status) :- shell(Command, Status).

%%	popen(+Command, +Mode, ?Stream)
%
%	@compat sicstus

popen(Command, Mode, Stream) :-
	open(pipe(Command), Mode, Stream).


		 /*******************************
		 *	 FILE OPERATIONS	*
		 *******************************/

%%	mkstemp(+Template, -File) is det.
%
%	Interface to the Unix function.  This emulation uses
%	tmp_file/2 and ignoress Template.
%
%	@deprecated This interface is a security-risc.  Use
%	tmp_file_stream/3.

mkstemp(_Template, File) :-
	tmp_file(mkstemp, File).

%%	tmpnam(-FileName)
%
%	Interface to tmpnam(). This emulation uses tmp_file/2.
%
%	@deprecated This interface is a security-risc.  Use
%	tmp_file_stream/3.

tmpnam(File) :-
	tmp_file(tmpnam, File).

%%	file_exists(+FileName) is semidet.
%
%	True if a file named FileName exists.
%
%	@compat sicstus

file_exists(FileName) :-
	exists_file(FileName).
