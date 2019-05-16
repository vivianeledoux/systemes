open Interface
open Sys
open Unix
open Marshal
   
module Th: S = struct
  type 'a process = (unit -> 'a)
  type 'a channel =  Unix.file_descr
  type 'a in_port = 'a channel
  type 'a out_port = 'a channel
  exception Pas_de_lecture

let new_channel () =
  Unix.pipe ()

let rec put v c () =
  Unix.lockf c F_LOCK 0;
  let b = Marshal.to_bytes v [] in
  let l = Bytes.length b in
  let lb = Bytes.make 1 (Char.chr l) in
  let _ = Unix.write c lb 0 1 in
  let _ = Unix.write c b 0 l in 
  Unix.lockf c F_ULOCK 0

let rec get c () =
  try
    Unix.lockf c F_TLOCK 1;
    Unix.lockf c F_RLOCK 0;
    let lb = Bytes.make 1 (Char.chr 0) in
    let _  = Unix.read c lb 0 1 in
    let n = Char.code (Bytes.get lb 0) in
    let l = Bytes.create n in
    let _ = Unix.read c l 0 n in
    Unix.lockf c F_ULOCK 0;
    Marshal.from_bytes l 0
  with
  | Unix.Unix_error (x, _, _)
    -> get c ()

let rec doco l () =
  match l with
  | [] -> ()
  | h::t -> begin
      match Unix.fork () with
      | 0 -> doco t () 
      | _ -> begin h (); let _ = Unix.wait () in ();  end
      end

let return v = (fun () -> v)

let bind e e' () =
  let v = e () in
  e' v ()

let run e = e ()
end
