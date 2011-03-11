#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>
#include <string.h>

enum {
    uniform,
    gaussian,
    parks,
} step_method;

float init_step_size;
float penalty_weight;
enum {
    kirkpatrick,
    white,
    constant,
} initial_temp_method;
float initial_temp;
int temp_length;
enum {
    huang,
    exponential,
} temp_decay_method;
float temp_decay;

float randf()
{
    return random() / powf(2, 31) + 1 / powf(2, 32);
}

float randn()
{
    float u1 = randf(), u2 = randf();

    return sqrtf(-2 * logf(u1)) * cosf(2*M_PI*u2);
}

float mean(float x[], int n)
{
    float sx = 0;

    for (int i=0; i<n; i++)
    {
        sx += x[i];
    }

    return sx / n;
}

float std(float x[], int n)
{
    float sx = 0, sxx = 0;

    for (int i=0; i<n; i++)
    {
        sx += x[i];
        sxx += x[i]*x[i];
    }

    return sqrt((sxx - sx*sx/n) / (n-1));
}

float bump(float x, float y)
{
    float cxs = cosf(x); cxs *= cxs;
    float cys = cosf(y); cys *= cys;

    return fabsf((cxs*cxs + cys*cys - 2*cxs*cys) / sqrtf(x*x+2*y*y));
}

float penalty(float x, float y)
{
#define BOUND(x) ((x) < 0 ? x : 0)
    return BOUND(x-0)+BOUND(10-x)+BOUND(y-0)+BOUND(10-y)+BOUND(15-x-y)+BOUND(x*y-0.75);
}

float T_kirkpatrick(float x[], int n)
{
    int n_neg = 0;
    float sx_neg = 0;

    for (int i=0; i<n; i++)
    {
        if (x[i] < 0)
        {
            sx_neg += -x[i];
            n_neg++;
        }
    }

    return - (sx_neg / n_neg) / logf(0.8);
}

float sa(unsigned seed)
{
    srandom(seed);

    float T;
    if (initial_temp_method != constant)
        T = INFINITY;
    else
        T = initial_temp;

    float step_size_x = init_step_size, step_size_y = init_step_size;
    float pos_x = 5, pos_y = 5;
    float obj = bump(pos_x, pos_y);
    float obj_pen = obj;

    int samples_remaining = 5000-1;

    float obj_d[5000];
    int n_obj_d = 0;
    float accepts[5000];
    int n_accepts = 0;

    int num_trials = 0, num_acceptances = 0;
    int initial_trials = 500;
    int max_trials = temp_length;
    int max_acceptances = 0.6*temp_length;

    float alpha = 0.1, omega = 2.1;

    float best_obj = obj;
    float best_x = pos_x, best_y = pos_y;
    int best_time = samples_remaining;

    while (samples_remaining > 0)
    {
        if (best_time - samples_remaining > 500)
        {
            best_time = samples_remaining;
            pos_x = best_x;
            pos_y = best_y;
            obj = best_obj;
            obj_pen = best_obj + penalty_weight * penalty(pos_x, pos_y) / T;

            step_size_x = step_size_y = init_step_size;
        }

        float step_x, step_y;
        if (step_method == gaussian)
        {
            step_x = step_size_x * randn();
            step_y = step_size_y * randn();
        }
        else
        {
            step_x = step_size_x * (2*randf()-1);
            step_y = step_size_y * (2*randf()-1);
        }

        float new_x = pos_x+step_x, new_y = pos_y+step_y;

        float new_pen = penalty_weight * penalty(new_x, new_y);

        if (T == INFINITY && new_pen != 0)
            continue;

        float new_obj = bump(new_x, new_y);
        float new_obj_pen = new_obj + new_pen / T;
        samples_remaining--;

        num_trials++;

        if (new_pen == 0)
        {
            if (new_obj > best_obj)
            {
                best_obj = new_obj;
                best_x = new_x;
                best_y = new_y;
                best_time = samples_remaining;
            }
        }

        float p;
        if (step_method == parks)
        {
            float step_norm = sqrtf(step_x*step_x + step_y*step_y);
            p = exp(- (obj_pen - new_obj_pen) / (T * step_norm));
        }
        else
        {
            p = exp(- (obj_pen - new_obj_pen) / T);
        }

        if (randf() < p)
        {
            num_acceptances++;
            obj_d[n_obj_d++] = new_obj_pen - obj_pen;
            pos_x = new_x;
            pos_y = new_y;
            obj = new_obj;
            obj_pen = new_obj_pen;

            accepts[n_accepts++] = new_obj_pen;

            if (T != INFINITY && step_method == parks)
            {
                step_size_x = (1-alpha)*step_size_x + alpha*omega*fabsf(step_x);
                step_size_y = (1-alpha)*step_size_y + alpha*omega*fabsf(step_y);
            }
        }

        bool reduced_T = false;

        if (T == INFINITY)
        {
            if (num_trials >= initial_trials)
            {
                if (initial_temp_method == kirkpatrick)
                    T = T_kirkpatrick(obj_d, n_obj_d);
                else if (initial_temp_method == white)
                    T = std(obj_d, n_obj_d);
                else
                {
                    fprintf(stderr, "unknown temp method");
                    exit(1);
                }
                reduced_T = true;
            }
        }
        else if (num_trials >= max_trials || num_acceptances >= max_acceptances)
        {
            if (temp_decay_method == huang)
            {
                float factor;
                if (n_accepts < 2)
                    factor = 0.9999;
                else
                {
                    factor = exp(-0.7*T/std(accepts, n_accepts));
                    if (factor < 0.5)
                        factor = 0.5;
                }
                T *= factor;
            }
            else
                T *= temp_decay;
            reduced_T = true;
        }

        if (reduced_T)
        {
            //printf("%g\n", T);
            n_obj_d = 0;
            num_trials = 0;
            num_acceptances = 0;
            n_accepts = 0;
        }
    }

    return best_obj;
}

int main(int argc, char **argv)
{
    if (argc != 8)
    {
        printf("needs 7 args\n");
        return 1;
    }

    int n_iters = atoi(argv[1]);

    if (strcmp(argv[2], "uniform") == 0)
        step_method = uniform;
    else if (strcmp(argv[2], "gaussian") == 0)
        step_method = gaussian;
    else if (strcmp(argv[2], "parks") == 0)
        step_method = parks;
    else
    {
        printf("unknown step method\n");
        return 1;
    }

    init_step_size = atof(argv[3]);
    penalty_weight = atof(argv[4]);
    
    if (strcmp(argv[5], "kirkpatrick") == 0)
        initial_temp_method = kirkpatrick;
    else if (strcmp(argv[5], "white") == 0)
        initial_temp_method = white;
    else
    {
        initial_temp_method = constant;
        initial_temp = atof(argv[5]);
    }

    temp_length = atoi(argv[6]);
    
    if (strcmp(argv[7], "huang") == 0)
        temp_decay_method = huang;
    else
    {
        temp_decay_method = exponential;
        temp_decay = atof(argv[7]);
    }

    float results[n_iters];

    for (int i=0; i<n_iters; i++)
    {
        results[i] = sa(getpid() * n_iters + i);
    }

    float m = mean(results, n_iters);
    float s = std(results, n_iters);

    printf("N(%g, %g)\n", m, s);
    printf("[%g, %g]\n", m-2*s/sqrt(n_iters), m+2*s/sqrt(n_iters));

    return 0;
}
