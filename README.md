# counters
Debug counters with Windows messaging IPC interface.

![screenshot](/screenshot.png "GUI")

This is a tool to support several simple debugging techniques. It accepts integer data from debugged program to display it on screen just as program goes. When you send messages from debugged program, this tool handles them immediately so, unlike with conventional debuggers and profilers, you can observe how your program works in realtime.

## Interface

It uses native Windows messaging for communication with all its limitations and advantages. It is actually language invariant, but I'll show all examples in C.

To send an integer number to some counter, use this:

    SendMessage((HWND)655890, WM_USER, i, n);

Here `i` is a counter index and `n` is the number you want to see in it. 655890 - is the handle of a counter's window. It is written on top of it and also accessible via clipboard.

To increment a counter use this:

    SendMessage((HWND)655890, WM_USER, 'I', i);

Note that 'I' works like a command here, so counter index is now the second argument.

Decrement a counter with this:

    SendMessage((HWND)655890, WM_USER, 'D', i);

And nullify counter with this:

    SendMessage((HWND)655890, WM_USER, '0', i);
    
Please note, that `0` here is a character, not a number. Sending 0 would just set 0-counter to `i`.

You can read value back, although only if it has been set with messages before, not by hand. And it affects performance, so it's generally best not to rely heavily on it.

    v = SendMessage((HWND)655890, WM_USER, 'R', i);

You can also use primitive time counter:

    SendMessage((HWND)655890, WM_USER, 'T', i);
    ... some workflow long enough to be measured in process quant time slices...
    SendMessage((HWND)655890, WM_USER, 'S', i);

Sending `T` starts the corresponding timer, sending `S` stops it and displays elapsed time in milliseconds. 

At this point you might be wondering, what the `button` button for? It is actually a button you can "outsource" from debugged program. It works like this, when you send a `B` command,

    b = SendMessage((HWND)655890, WM_USER, 'B', 0);

It returns 1 or more if a `button` was pressed, and then resets its state. This way you can use it as some kind of a trigger in your debug session. I know, it looks a bit silly, but it actually helps a lot.

## GUI

* `[0]` button nullifies all counters.
* `[N]` button updates counters when `Realtime print` is off.
* `[W]` button copies handler number to clipboard.
* `[C]` button copies C SendMessage template to clipboard.
* `[F]` button saves counters to a file.
* `[v] Realtime print` is a checkbox which sets automatic counter updates on and off. It is convenient to have it always `on`, but is also affects perforance, so this is optional.
* `[button]` button counts when you press it so you can read if it has been pressed via messaging afterwards.

## Executable

If you don't want to get into MASM32 thing, here's prebuilt exe: https://www.dropbox.com/s/g03xew4xl2o25dv/counters.exe?dl=0 
