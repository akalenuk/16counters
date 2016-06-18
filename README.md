# counters
Debug counters with Windows messaging IPC interface.

![screenshot](/screenshot.png "GUI")

This is a tool to support several simple debugging techniques. It accepts integer data from debugged program to display it on screen just as program goes. 

*Interface*

It uses native Windows messaging for communication with all its limitations and advantages. It is actually language invariant, but I'll show all examples in C.

To send an integer number to some counter, use this:

    SendMessage((HWND)197138, WM_USER, i, n);

Where `i` is a counter index and `n` is the number you want to see in it. 197138 - is the handle of a counters window. It is written on top of it and also accessible via clipboard.

To increment a counter use this:

    SendMessage((HWND)197138, WM_USER, 'I', i);

Note that 'I' works like a command here, so index went to the second argument.

Decrement a counter with this:

    SendMessage((HWND)197138, WM_USER, 'D', i);

You can read value back, although only if it has been set with messages before, not by hand.

    v = SendMessage((HWND)197138, WM_USER, 'R', i);

You can also use primitive time counter:

    SendMessage((HWND)197138, WM_USER, 'T', i);
    ... some workflow long enough to be measured in process quant time slices...
    SendMessage((HWND)197138, WM_USER, 'S', i);

Sending `T` starts the corresponding timer, sending `S` stops it and displays elapsed time in milliseconds. 

There is an option to nullify counter:

    SendMessage((HWND)197138, WM_USER, '0', i);

Please note, that `0` here is a character, not a number. Sending 0 would just set 0-counter to `i`.

At this point you might be wondering, what the `button` button for? It is actually a button you can "outsource" from debugged program. It works like this, when you send this:

    b = SendMessage((HWND)197138, WM_USER, 'B', 0);

It returns not 0 if a `button` was pressed and then resets its state. This way you can use it as some kind of a trigger in your debug session. I know it looks a bit silly, but it actually helps a lot.

*GUI*

`[0]` button nullifies all counters.
`[N]` button updates counters when `Realtime print` is off.
`[W]` button copies handler number to clipboard.
`[C]` button copies C SendMessage template to clipboard.
`[F]` button saves counters to a file.
`[v] Realtime print` is a checkbox which sets automatic counter updates on and off. It is convenient to have it always `on`, but is also affects perforance, so this is optional.
`[button]` button counts when you press it so you can access this counter via messaging then.
