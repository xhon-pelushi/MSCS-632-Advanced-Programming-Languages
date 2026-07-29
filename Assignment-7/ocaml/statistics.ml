(*
 * Assignment 7 — Multi-Paradigm Problem Solving
 * OCaml (Functional): mean, median, and mode of a list of integers.
 *
 * Immutable lists, higher-order functions (fold_left, map, filter), and
 * no mutable state.
 *)

(* Arithmetic mean via fold_left. *)
let mean (xs : int list) : float =
  match xs with
  | [] -> 0.0
  | _ ->
      let sum = List.fold_left ( + ) 0 xs in
      float_of_int sum /. float_of_int (List.length xs)

(* Median: sort a fresh list, then pick the middle value(s). *)
let median (xs : int list) : float =
  match xs with
  | [] -> 0.0
  | _ ->
      let sorted = List.sort compare xs in
      let n = List.length sorted in
      if n mod 2 = 1 then
        float_of_int (List.nth sorted (n / 2))
      else
        let a = List.nth sorted (n / 2 - 1) in
        let b = List.nth sorted (n / 2) in
        (float_of_int a +. float_of_int b) /. 2.0

(* Count occurrences of v in xs. *)
let count_of (v : int) (xs : int list) : int =
  List.fold_left (fun acc x -> if x = v then acc + 1 else acc) 0 xs

(* Unique values, preserving first-seen order. *)
let unique (xs : int list) : int list =
  List.fold_left
    (fun acc x -> if List.mem x acc then acc else acc @ [x])
    []
    xs

(*
 * Mode(s): every value whose frequency equals the maximum frequency.
 * Built by composing unique / map / fold / filter over immutable lists.
 *)
let mode (xs : int list) : int list =
  match xs with
  | [] -> []
  | _ ->
      let vals = unique xs in
      let freqs = List.map (fun v -> (v, count_of v xs)) vals in
      let max_freq =
        List.fold_left (fun m (_, c) -> if c > m then c else m) 0 freqs
      in
      freqs
      |> List.filter (fun (_, c) -> c = max_freq)
      |> List.map fst

(* ---- Demo driver ------------------------------------------------------- *)

let string_of_int_list xs =
  "[" ^ String.concat ", " (List.map string_of_int xs) ^ "]"

let () =
  let data = [4; 1; 2; 2; 3; 4; 4; 5] in
  Printf.printf "=== OCaml (Functional) Statistics Calculator ===\n";
  Printf.printf "Input list: %s\n" (string_of_int_list data);
  Printf.printf "Mean:   %.4f\n" (mean data);
  Printf.printf "Median: %.4f\n" (median data);
  Printf.printf "Mode:   %s (frequency peak)\n" (string_of_int_list (mode data))
