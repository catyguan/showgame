#include "Coder.h"
#include <string.h>

// VarValue
VarValue::VarValue() {
	type = VVT_NULL;
}

VarValue::~VarValue() {
	Clear();	
}

void VarValue::Clear() {
	switch(type) {
	case VVT_LIST: {
			std::vector<VarValue*>::const_iterator it;
			for(it=l.begin();it!=l.end();it++) {
				VarValue* p = *it;
				delete p;
			}
			l.clear();
		}
		break;
	case VVT_MAP: {
			std::map<std::string, VarValue*>::const_iterator it;
			for(it=m.begin();it!=m.end();it++) {
				VarValue* p = it->second;
				delete p;
			}
			m.clear();
		}
		break;
	case VVT_LEN_STRING:
		s.clear();
		break;
	}	
	type = VVT_NULL;
}

// Coder
bool Coder::readBool(Buffer* buf, int* err)
{
	int c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return false;
	}
	return c!=0;
}

int Coder::writeBool(Buffer* buf, bool v)
{
	buf->Write(v?1:0);
	return 1;
}

int8_t Coder::readFixInt8(Buffer *buf, int* err)
{	
	int c;	
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	return (int8_t) c;
}

int Coder::writeFixInt8(Buffer *buf, int8_t v)
{
	buf->Write((char) (v));
	return 1;
}

int16_t Coder::readFixInt16(Buffer *buf, int* err)
{	
	int16_t v = 0;
	int c;	
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 8;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF);
	return v;
}

int Coder::writeFixInt16(Buffer *buf, int16_t v)
{
	buf->Write((char) (v >> 8));
	buf->Write((char) (v));
	return 2;
}

int32_t Coder::readFixInt32(Buffer *buf, int* err)
{	
	int32_t v = 0;
	int c;	
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 24;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 16;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 8;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF);
	return v;
}

int Coder::writeFixInt32(Buffer *buf, int32_t v)
{
	buf->Write((char) (v >> 24));
	buf->Write((char) (v >> 16));
	buf->Write((char) (v >> 8));
	buf->Write((char) (v));
	return 4;
}

int64_t Coder::readFixInt64(Buffer *buf, int* err)
{	
	int64_t v = 0;
	int c;	
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=((int64_t)(c & 0xFF)) << 56;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=((int64_t)(c & 0xFF)) << 48;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v += ((int64_t)(c & 0xFF)) << 40;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=((int64_t)(c & 0xFF)) << 32;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 24;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 16;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF) << 8;
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	v +=(c & 0xFF);
	return v;
}

int Coder::writeFixInt64(Buffer *buf, int64_t v)
{
	buf->Write((char) (v >> 56));
	buf->Write((char) (v >> 48));
	buf->Write((char) (v >> 40));
	buf->Write((char) (v >> 32));
	buf->Write((char) (v >> 24));
	buf->Write((char) (v >> 16));
	buf->Write((char) (v >> 8));
	buf->Write((char) (v));
	return 8;
}

float Coder::readFloat32(Buffer* buf, int* err)
{
	uint32_t y = readFixUint32(buf, err);
	float x;
	memcpy_s(&x, 4, &y, 4);
	return x;
}

int Coder::writeFloat32(Buffer* buf, float v)
{
	uint32_t y;
    memcpy_s(&y, 4, &v, 4);
	writeFixUint32(buf, y);
	return 4;
}

double Coder::readFloat64(Buffer* buf, int* err)
{
	uint64_t y = readFixUint64(buf, err);
	double x;
	memcpy_s(&x, 8, &y, 8);
	return x;
}

int Coder::writeFloat64(Buffer* buf, double v)
{
	uint64_t y;
    memcpy_s(&y, 8, &v, 8);
	writeFixUint64(buf, y);
	return 8;
}

uint16_t Coder::readUint16(Buffer *buf, int* err) {
	return (uint16_t) readUint64(buf, err);
}

int Coder::writeUint16(Buffer *buf, uint16_t v) {
	return writeUint64(buf, (uint64_t) v);
}

uint32_t Coder::readUint32(Buffer *buf, int* err) {
	return (uint32_t) readUint64(buf, err);
}

int Coder::writeUint32(Buffer *buf, uint32_t v) {
	return writeUint64(buf, (uint64_t) v);
}

uint64_t Coder::readUint64(Buffer *buf, int* err) {
	int64_t s = 0;
	int b;
	int w = 0;
	int count = buf->Remain();
	int i = 0;
	while(count != 0){
		b =  buf->Read();
		if(b<=0) {
			if(err!=NULL)*err=b;
			return 0;
		}
		if(b < 0x80){
			if (i > 9 || i == 9 && b > 1 ){
				if(err!=NULL)*err=-2;
				return 0; // overflow
			}
			return (s | (long)(b) << w);

		}
		s |= ((int64_t)(b & 0x7f)) << w;
		w += 7;
		count--;
	}
	return 0;
}

int Coder::writeUint64(Buffer *buf, uint64_t v) {
	int i = 0;
	while(v >= 0x80){		
		buf->Write((char) (v | 0x80)) ;
		v >>= 7;
		i++;
	}
	buf->Write((char) v);
	return i + 1;
}

int16_t Coder::readInt16(Buffer *buf, int* err) {
	return (int16_t) readInt64(buf, err);
}

int Coder::writeInt16(Buffer *buf, int16_t v) {
	return writeInt64(buf, (int64_t) v);
}

int32_t Coder::readInt32(Buffer *buf, int* err) {
	return (int32_t) readInt64(buf, err);
}

int Coder::writeInt32(Buffer *buf, int32_t v) {
	return writeInt64(buf, (int64_t) v);
}

int64_t Coder::readInt64(Buffer *buf, int* err) {
	uint64_t l = readUint64(buf, err);
	int64_t l2 = (int64_t) (l >> 1);
	if((l & 1) != 0){
		l2 = ~l2;
	}
	return l2;
}

int Coder::writeInt64(Buffer *buf, int64_t v) {
	uint64_t l1 = v << 1;
	if(v < 0){
		l1 = ~l1;
	}
	return writeUint64(buf, l1);
}

std::string Coder::readString(Buffer *buf, int* err) {
	int c = buf->Remain();
	if(c==0) {
		return std::string();
	}
	std::string s;
	s.resize(c);
	buf->ReadBytes(&s[0], c);
	return s;
}

int Coder::writeString(Buffer* buf, std::string v) {
	return buf->WriteBytes(v.c_str(), v.length());
}

std::string Coder::readLenString(Buffer *buf, int* err) {
	int32_t l = readInt32(buf, err);
	if(l==0) {
		return std::string();
	}
	if(l>buf->Remain()) {
		if(err!=NULL)*err=-2;
		return std::string();
	}
	std::string s;
	s.resize(l);
	buf->ReadBytes(&s[0], l);
	return s;
}

int Coder::writeLenString(Buffer* buf, std::string v) {
	int l = writeInt32(buf, v.length());
	return writeString(buf, v)+l;	
}

VarValue* Coder::readVar(Buffer *buf, int* err) {
	int ty = buf->Read();
	if(ty<0) {
		if(err!=NULL)*err=ty;
		return 0;
	}
	int merr = 0;
	int *perr = err==NULL?&merr:err;
	switch(ty) {
	case VVT_BOOLEAN: {
			bool v = readBool(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvBool(v);
		}
		break;	
	case VVT_INT:
	case VVT_INT32: {
			int32_t v = readInt32(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvInt32(v);
		}
		break;
	case VVT_INT8: {
			int8_t v = readFixInt8(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvInt8(v);
		}
		break;
	case VVT_UINT8:{
			uint8_t v = readFixUint8(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvUint8(v);
		}
		break;
	case VVT_INT16:{
			int16_t v = readInt16(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvInt16(v);
		}
		break;
	case VVT_INT64:{
			int64_t v = readInt64(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvInt64(v);
		}
		break;
	case VVT_UINT16:{
			uint16_t v = readUint16(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvUint16(v);
		}
		break;
	case VVT_UINT32:{
			uint32_t v = readUint32(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvUint32(v);
		}
		break;
	case VVT_UINT64:{
			uint64_t v = readUint64(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvUint64(v);
		}
		break;
	case VVT_FLOAT32:{
			float v = readFloat32(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvFloat32(v);
		}
		break;
	case VVT_FLOAT64:{
			double v = readFloat64(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvFloat64(v);
		}
		break;
	case VVT_MAP: {
			int32_t c = readInt32(buf, perr);
			if(*perr!=0)return NULL;
			VarValue* r = VarValue::vvMap();
			for(int32_t i=0;i<c;i++) {
				std::string key = readLenString(buf, perr);
				if(*perr!=0) {
					delete r;
					return NULL;
				}
				VarValue* v = readVar(buf, perr);
				if(*perr!=0) {
					delete r;
					return NULL;
				}
				r->m[key] = v;
			}
			return r;
		}
		break;
	case VVT_LIST: {
			int32_t c = readInt32(buf, perr);
			if(*perr!=0)return NULL;
			VarValue* r = VarValue::vvList();
			for(int32_t i=0;i<c;i++) {
				VarValue* v = readVar(buf, perr);
				if(*perr!=0) {
					delete r;
					return NULL;
				}
				r->l.push_back(v);
			}
			return r;
		}
		break;
	case VVT_LEN_STRING:	{
			std::string s = readString(buf, perr);
			if(*perr!=0)return NULL;
			return VarValue::vvString(s);
		}
		break;
	}
	return NULL;
}

int Coder::writeVar(Buffer* buf, VarValue* v) {
	if(v==NULL) {
		return buf->Write(VVT_NULL);
	}
	int l1 = buf->Write((char) v->type);
	int l2 = 0;
	switch(v->type) {
	case VVT_BOOLEAN:
		l2 = writeBool(buf, v->b);
		break;	
	case VVT_INT:
	case VVT_INT32:
		l2 = writeInt32(buf, v->i32);
		break;
	case VVT_INT8:
		l2 = writeFixInt8(buf, v->i8);
		break;
	case VVT_UINT8:
		l2 = writeFixUint8(buf, v->ui8);
		break;
	case VVT_INT16:
		l2 = writeInt16(buf, v->i16);
		break;
	case VVT_INT64:
		l2 = writeInt64(buf, v->i64);
		break;
	case VVT_UINT16:
		l2 = writeUint16(buf, v->ui16);
		break;
	case VVT_UINT32:
		l2 = writeUint32(buf, v->i32);
		break;
	case VVT_UINT64:
		l2 = writeUint64(buf, v->i64);
		break;
	case VVT_FLOAT32:
		l2 = writeFloat32(buf, v->f32);
		break;
	case VVT_FLOAT64:
		l2 = writeFloat64(buf, v->f64);
		break;
	case VVT_MAP: {
			int c = v->m.size();
			l2 = writeInt32(buf, (int32_t) c);
			std::map<std::string, VarValue*>::const_iterator it;
			for(it=v->m.begin();it!=v->m.end();it++) {
				l2 += writeLenString(buf, it->first);
				l2 += writeVar(buf, it->second);
			}			
		}
		break;
	case VVT_LIST: {
			int c = v->l.size();
			l2 = writeInt32(buf, (int32_t) c);
			std::vector<VarValue*>::const_iterator it;
			for(it=v->l.begin();it!=v->l.end();it++) {
				l2 += writeVar(buf, *it);
			}
		}
		break;
	case VVT_LEN_STRING:	
		l2 = writeLenString(buf, v->s);
		break;
	}
	return l1+l2;
}