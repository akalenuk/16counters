# counters
Professionally, I work on a Software Development Toolkit for 3D-printing applications. It's a sack of algorithms and data structures. I get to play with curves, meshes, voxels, and images. But it has no GUI on its own and sometimes this makes things cumbersome.

In 2006, I was in a similar position. I've been working on a 3D-engine with vectors, and triangles, and quaternions. But without any UI. Back then, I came up with the ersatz-GUI: an array of integer counters managed via WinAPI messaging. I named it *counters*.

It's written in assembly which is good for visibility. You know that there are no hidden overheads, it doesn't eat up a lot of memory, and its performance doesn't depend on the compiler version. It's a separate process so it doesn't crash or hang when the main one does. And this is good for debugging when you want your program to stop every now and then. It's a separate window so Windows manages the message query instead of some third-party broker. And this is good for sustainability, it is 14 years old now and everything works as it was supposed to.

## Messages

It uses native Windows messaging for communication. In Windows, every window has a handler. It's like a phone number. We can call every window, *counters* included, and ask it to do something for us. With *counters*, the whole messaging interface is just 7 messages.

If you want to send an integer to a specific counter, send it with this message:

    SendMessage((HWND)counters_window_handler, WM_USER, counter_idx, value);

To read a counter, use this:

    counter_value = SendMessage((HWND)counters_window_handler, WM_USER, 'R', counter_idx);

It's quite common to simply increment and decrement counters so there are special messages for it.

    SendMessage((HWND)655890, WM_USER, 'I', counter_idx);   // increment a counter

    SendMessage((HWND)655890, WM_USER, 'D', counter_idx);   // decrement a counter

It is uncommon either to nullify a counter:

    SendMessage((HWND)655890, WM_USER, '0', counter_idx);   // nullify a counter
    
Please note, that `0` here is a character, not a number. Sending 0 would just set 0-counter to `i`.

The last two messages are about timing. Please note that this is not an accurate way to measure time. Nothing wrong with the timestamps but the messaging itself goes in quants. Generally, you shouldn't measure anything in milliseconds not to mention microseconds with this timer.

But if you want some rough measurement, for instance, when you run an algorithm that runs for ten seconds and you want to check that it still runs for ten seconds after you change something, it's fine. It goes like this:

    SendMessage((HWND)655890, WM_USER, 'T', counter_idx);
    ... some workflow long enough to be measured roughly...
    SendMessage((HWND)655890, WM_USER, 'S', counter_idx);

Sending `T` starts the corresponding timer. Sending `S` stops it and displays elapsed time in milliseconds. 


## Buttons

* `[0]` button nullifies all counters.
* `[N]` button updates counters when `realtime` option is off.
*  `realtime` checkbox turns printing on and off. It might get laggy if you send tons of messages. This fixes the problem.
* `[W]` button copies handler number (remember `counters_window_handler`?) to the clipboard.
* `[C]` button copies a C-style SendMessage template to the clipboard.
* `[T]` button copies all the counters to the clipboard.


## When it helps

I found it indispensable for tuning-up progress reporting. It's when your algorithm is crunching data and you want to know is it there yet at every given moment. You know, 0%, 5%, 10%, then 75%, and then 146%. This is something you would generally need a whole application with its dialogs, and slots, and events, and whatnot. Or you can use *counters*.

It also helps if you want to get some kind of performance monitoring when refactoring. It's when you move things around and suddenly your preprocessing takes 8 seconds instead of 2. Not a big thing if the whole algorithm runs for a minute but definitely a trigger to stop and rethink. Yes, a dedicated benchmark or a profiler will do this better but I don't run a profiler every time I rename a variable. Which, considering name shadowing, might not be the worst idea ever.

Or to count things from different threads. Like every time a thread processes a slice of image data, I increment a counter. Then I see 4096 reported slices for 78 real slices in the input and this explains why a simple image filter runs for a whole minute to begin with.

It's a simple thing that helps me in solving complex problems. If it could help you too, I'll be happy.
