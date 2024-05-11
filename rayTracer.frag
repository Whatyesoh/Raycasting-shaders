//
//Structs
//

extern Image sphereTexture;
extern number width;
extern number height;

struct ray {
    vec3 orig;
    vec3 dir;
};

struct hitRecord {
    vec3 p;
    vec3 normal;
    float t;
    bool frontFace;
    bool hit;
    int i;
};

struct sphere {
    vec3 center;
    float radius;
    vec4 color;
    bool tex;
    int id;
};

struct light {
    vec4 color;
    vec3 position;
    vec3 dir;
    bool sun;
};

float lengthSquared(vec3 v) {
    return v.x * v.x + v.y * v.y + v.z * v.z;
}

vec3 unitVector (vec3 v) {
    return v / (sqrt(pow(v.x,2)+pow(v.y,2)+pow(v.z,2)));
}

extern float random;
float seed = random;

float rand(){
    seed = fract(sin(dot(vec2(seed,seed), vec2(12.9898, 78.233))) * 43758.5453);
    return seed;
}

vec3 rayAt (ray r, float t) {
    return r.orig + t * r.dir;
}

vec3 sampleSquare() {
    return vec3(rand()-.5, rand()-.5, 0);
}

ray getRay(number i,number j, vec3 pixelOrigin, vec3 cameraCenter, vec3 pDU, vec3 pDV, float total, float current) {
    float sideLength = sqrt(total);
    vec3 offset = vec3((current / total) - .5,(current - current / sideLength)/sideLength-.5, 0 );
    vec3 pixelSample = pixelOrigin + ((i + offset.x) * pDU) + ((j + offset.y) * pDV);
    vec3 rayOrigin = cameraCenter;
    vec3 rayDirection = pixelSample - rayOrigin;

    return ray(rayOrigin,rayDirection);
}

bool hitSphere(sphere s, ray r, float tmin, float tmax, out hitRecord rec, hitRecord tempRec, int i) {
    rec = tempRec;
    vec3 oc = s.center - r.orig;
    float a = dot(r.dir,r.dir);
    float h = dot(r.dir,oc);
    float c = dot(oc,oc) - s.radius*s.radius;
    float discriminant = h * h - a * c;
    
    if (discriminant < 0) {
        return false;
    }
    
    float sqrtd = sqrt(discriminant);

    float root = (h - sqrtd) / a;

    if (root <= tmin || root >= tmax) {
        root = (h + sqrtd) / a;
        if (root <= tmin || root >= tmax) {
            return false;
        }
    }

    rec.t = root;
    rec.i = i;
    rec.p = rayAt(r, rec.t);
    rec.hit = true;
    vec3 outwardNormal = (rec.p - s.center) / s.radius;
    rec.frontFace = dot(r.dir,outwardNormal) < 0;
    rec.normal = rec.frontFace ? outwardNormal : -outwardNormal;

    return true;
}

vec4 rayColor (ray r, out hitRecord rec, sphere[2] worldSpheres, light[1] worldLights, vec4 ambient) {
    hitRecord tempRec;
    rec.hit = false;
    rec.t = 100000;
    for (int i = 0; i < worldSpheres.length(); i++) {
        tempRec = rec;
        hitSphere(worldSpheres[i],r,0,rec.t,rec,tempRec,i);
    }
    if (rec.hit) {
        vec4 hitColor = ambient;
        if (worldSpheres[rec.i].tex) {
            //hitColor += vec4(rec.normal.z,rec.normal.z,rec.normal.z,1);
            float xPoint = rec.normal.x/4+.25;
            if (rec.normal.z <= 0) {
                xPoint = 1 - xPoint;
            }
            float yPoint = 1 - (rec.normal.y/2+.5);
            if (worldSpheres[rec.i].id == 1) {
                hitColor += Texel(sphereTexture,vec2(xPoint,yPoint));
            }
        }
        else {
            hitColor += worldSpheres[rec.i].color;
        }
        r.orig = rec.p;
        for (int i = 0; i < worldLights.length(); i++) {
                hitRecord dummy;
                dummy.hit = false;
                r.dir = (worldLights[i].position - r.orig);
                for (int j = 0; j < worldSpheres.length(); j++) {
                    //if (rec.i == 0) {
                        //return vec4(0,0,0,0);
                    //}
                    if (rec.i != j) {
                        tempRec = dummy;
                        hitSphere(worldSpheres[j],r,0,100000,dummy,tempRec,j);
                    }
                }
                if (dummy.hit) {
                    //hitColor -= .7;
                }
                else {
                    if(worldLights[i].sun) {
                        hitColor += 1.5 * dot(rec.normal,worldLights[i].position-rec.p)/(sqrt(lengthSquared(rec.normal)) * sqrt(lengthSquared(worldLights[i].position-rec.p)));
                    }
                    else {
                        //hitColor += .3 * dot(rec.normal,-worldLights[i].dir)/(sqrt(lengthSquared(rec.normal)) * sqrt(lengthSquared(-worldLights[i].dir)));
                    }
                }
        }
        return hitColor / 3;
    }
    else {
        vec3 unitDirection = unitVector(r.dir);
        float a = .5 * (unitDirection.y + 1);
        return vec4(0,0,0,1);
        //return ((1-a) * vec4(1,1,1,1) + a * vec4(.25,.25,25,1));
    }
}


//extern float mouseX;

float vPHeight = 2;
float vPWidth = vPHeight * (width/height);
number samplesPerPixel = 1;

extern vec3 lookFrom = vec3(0,100,0);
vec3 cameraCenter = lookFrom;
extern vec3 lookAt = vec3(0,100,-1);
float focalLength = sqrt(lengthSquared(lookAt-lookFrom));
vec3 vup = 1.01 * lookFrom;
vec3 w = unitVector(lookFrom-lookAt);
vec3 u = unitVector(cross(vup,w));
vec3 v = cross(w,u);

vec3 vPU = vPWidth * u;
vec3 vPV = vPHeight * -v;
vec3 pDU = vPU / width;
vec3 pDV = vPV / height;
vec3 vUL = cameraCenter - (focalLength * w) - vPU/2 - vPV/2;
vec3 pixelOrigin = vUL + .5 * pDV + .5 * pDU;

//
//Main Shader Code
//

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 xy) {
    float infinity = 10000000;

    hitRecord rec;
    rec.hit = false;
    rec.t = infinity;
    hitRecord tempRec;

    sphere worldSpheres[2];
    worldSpheres[0] = sphere(vec3(0,100.5,0),.5,vec4(.75,.75,.75,1),true,1);
    worldSpheres[1] = sphere(vec3(0,0,0),100,vec4(1,1,1,1),false,1);

    light worldLights[1];
    worldLights[0] = light(vec4(1,.9,.8,1),vec3(0,104,-2),vec3(0,0,0),true);

    ray r;
    color = vec4(0,0,0,0);

    for (int j = 0; j < samplesPerPixel; j++) {
        r = getRay(xy.x, xy.y, pixelOrigin, cameraCenter, pDU, pDV,samplesPerPixel,j);
        color += rayColor(r, rec,worldSpheres, worldLights,vec4(.5,.7,1,1));
    }
    return color/samplesPerPixel;
}