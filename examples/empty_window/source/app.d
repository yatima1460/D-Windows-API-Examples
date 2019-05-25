module simplewindow;

import core.runtime;
import std.string;
import std.utf;

import core.sys.windows.windows;

extern (Windows) long WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
        LPSTR lpCmdLine, int iCmdShow)
{
    ulong result;
    void exceptionHandler(Throwable e)
    {
        throw e;
    }

    try
    {
        Runtime.initialize();
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
        Runtime.terminate();
    }
    catch (Throwable o)
    {
        MessageBox(null, o.toString().toUTF16z, "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;
    }

    return result;
}

ulong myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    // Register the window class.
    const string CLASS_NAME = "Sample Window Class";

    WNDCLASS wc = {};

    wc.lpfnWndProc = &WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = cast(wchar*) CLASS_NAME;

    RegisterClass(&wc);

    // Create the window.

    HWND hwnd = CreateWindowEx(0, // Optional window styles.
            cast(wchar*) CLASS_NAME, // Window class
            "D native window", // Window text
            WS_OVERLAPPEDWINDOW, // Window style

            // Size and position
            CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, // Parent window    
            NULL, // Menu
            hInstance, // Instance handle
            NULL // Additional application data
            );

    if (hwnd == NULL)
    {
        return 0;
    }

    ShowWindow(hwnd, nCmdShow);

    // Run the message loop.

    MSG msg = {};
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

extern (Windows) LRESULT WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) nothrow
{
    switch (uMsg)
    {
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;

    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            FillRect(hdc, &ps.rcPaint, cast(HBRUSH)(COLOR_WINDOW + 1));

            EndPaint(hwnd, &ps);
        }

        return 0;

    default:
        break;

    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
