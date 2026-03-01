#include "third_party/sokol/sokol.h"
#include "shaders/triangle.glsl.h"

#define impl
#include "third_party/na/na.h"

static struct {
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
} state;

void init(void)
{
    sg_setup(&(sg_desc){
        .environment = sglue_environment(),
        .logger.func = slog_func,
    });

    // a vertex buffer with 3 vertices and view for binding
    float vertices[] = {
        // positions            // colors
         0.0f,  0.5f, 0.5f,     1.0f, 0.0f, 0.0f, 1.0f,
         0.5f, -0.5f, 0.5f,     0.0f, 1.0f, 0.0f, 1.0f,
        -0.5f, -0.5f, 0.5f,     0.0f, 0.0f, 1.0f, 1.0f
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
        .data = SG_RANGE(vertices),
        .label = "vertex-buffer"
    });

    // create shader from code-generated sg_shader_desc
    sg_shader shd = sg_make_shader(triangle_shader_desc(sg_query_backend()));

    // create a pipeline object (default render states are fine for triangle)
    state.pip = sg_make_pipeline(&(sg_pipeline_desc){
        .shader = shd,
        // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
        .layout = {
            .attrs = {
                [ATTR_triangle_position].format = SG_VERTEXFORMAT_FLOAT3,
                [ATTR_triangle_color0].format = SG_VERTEXFORMAT_FLOAT4
            }
        },
        .label = "triangle-pipeline",
        .sample_count = 4,
    });

    // a pass action to clear framebuffer to black
    state.pass_action = (sg_pass_action) {
        .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value={0.0f, 0.0f, 0.0f, 1.0f } },
    };
}

void event(const sapp_event* event)
{
    if (event->type == SAPP_EVENTTYPE_KEY_DOWN && !event->key_repeat) {
        if (event->key_code == SAPP_KEYCODE_F11) {
            sapp_toggle_fullscreen();
        }
        if (event->key_code == SAPP_KEYCODE_ENTER && (event->modifiers & SAPP_MODIFIER_ALT) != 0) {
            sapp_toggle_fullscreen();
        }
    }
}

void frame(void)
{
    sg_swapchain swapchain = sglue_swapchain();
    sg_begin_pass(&(sg_pass){ .action = state.pass_action, .swapchain = swapchain });
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_draw(0, 3, 1);
    sg_end_pass();
    sg_commit();
}

void cleanup(void)
{
    sg_shutdown();
}

int main(int argc, char* argv[])
{
    sapp_run(&(sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 1280,
        .height = 720,
        .high_dpi = true,
        .sample_count = 4,
        .window_title = "Sokol Starter Pack",
        .logger.func = slog_func,
    });

    return 0;
}

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#define VC_EXTRALEAN
#define NOMINMAX
#include <windows.h>

int APIENTRY WinMain(HINSTANCE instance, HINSTANCE prev_inst, LPSTR cmd, int show)
{
    HMODULE kernel32 = LoadLibraryA("kernel32.dll");
    HMODULE shell32  = LoadLibraryA("shell32.dll");

    typedef WCHAR*  Win32_GetCommandLineW(void);
    typedef WCHAR** Win32_CommandLineToArgvW(WCHAR*, int*);

    Win32_GetCommandLineW    *GetCommandLineW    = (Win32_GetCommandLineW*)  GetProcAddress(kernel32, "GetCommandLineW");
    Win32_CommandLineToArgvW *CommandLineToArgvW = (Win32_CommandLineToArgvW*)GetProcAddress(shell32, "CommandLineToArgvW");

    int argc = 0;
    WCHAR **argv_w = CommandLineToArgvW(GetCommandLineW(), &argc);
    Arena *arena = arena_alloc(Megabytes(1));

    char **argv = PushArray(arena, char*, argc);
    for (int i = 0; i < argc; i++)
    {
        String arg = string_from_string16(arena, string16_from_cstr((u16 *)argv_w[i]));
        argv[i] = (char*)arg.data;
    }

    LocalFree(argv_w);

    return main(argc, argv);
}
#endif // defined(_WIN32)