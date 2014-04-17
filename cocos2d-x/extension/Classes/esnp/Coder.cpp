#include "Coder.h"
#include <string.h>

// ESNPCoder
bool ESNPCoder::readBool(ESNPBuffer* buf, int* err)
{
	int c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return false;
	}
	return c!=0;
}

int ESNPCoder::writeBool(ESNPBuffer* buf, bool v)
{
	buf->Write(v?1:0);
	return 1;
}

int8_t ESNPCoder::readFixInt8(ESNPBuffer *buf, int* err)
{	
	int c;	
	c = buf->Read();
	if(c<0) {
		if(err!=NULL)*err=c;
		return 0;
	}
	return (int8_t) c;
}

int ESNPCoder::writeFixInt8(ESNPBuffer *buf, int8_t v)
{
	buf->Write((char) (v));
	return 1;
}

int16_t ESNPCoder::readFixInt16(ESNPBuffer *buf, int* err)
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

int ESNPCoder::writeFixInt16(ESNPBuffer *buf, int16_t v)
{
	buf->Write((char) (v >> 8));
	buf->Write((char) (v));
	return 2;
}

int32_t ESNPCoder::readFixInt32(ESNPBuffer *buf, int* err)
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

int ESNPCoder::writeFixInt32(ESNPBuffer *buf, int32_t v)
{
	buf->Write((char) (v >> 24));
	buf->Write((char) (v >> 16));
	buf->Write((char) (v >> 8));
	buf->Write((char) (v));
	return 4;
}

int64_t ESNPCoder::readFixInt64(ESNPBuffer *buf, int* err)
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

int ESNPCoder::writeFixInt64(ESNPBuffer *buf, int64_t v)
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

float ESNPCoder::readFloat32(ESNPBuffer* buf, int* err)
{
	uint32_t y = readFixUint32(buf, err);
	float x;
	memcpy_s(&x, 4, &y, 4);
	return x;
}

int ESNPCoder::writeFloat32(ESNPBuffer* buf, float v)
{
	uint32_t y;
    memcpy_s(&y, 4, &v, 4);
	writeFixUint32(buf, y);
	return 4;
}

double ESNPCoder::readFloat64(ESNPBuffer* buf, int* err)
{
	uint64_t y = readFixUint64(buf, err);
	double x;
	memcpy_s(&x, 8, &y, 8);
	return x;
}

int ESNPCoder::writeFloat64(ESNPBuffer* buf, double v)
{
	uint64_t y;
    memcpy_s(&y, 8, &v, 8);
	writeFixUint64(buf, y);
	return 8;
}

uint16_t ESNPCoder::readUint16(ESNPBuffer *buf, int* err) {
	return (uint16_t) readUint64(buf, err);
}

int ESNPCoder::writeUint16(ESNPBuffer *buf, uint16_t v) {
	return writeUint64(buf, (uint64_t) v);
}

uint32_t ESNPCoder::readUint32(ESNPBuffer *buf, int* err) {
	return (uint32_t) readUint64(buf, err);
}

int ESNPCoder::writeUint32(ESNPBuffer *buf, uint32_t v) {
	return writeUint64(buf, (uint64_t) v);
}

uint64_t ESNPCoder::readUint64(ESNPBuffer *buf, int* err) {
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

int ESNPCoder::writeUint64(ESNPBuffer *buf, uint64_t v) {
	int i = 0;
	while(v >= 0x80){		
		buf->Write((char) (v | 0x80)) ;
		v >>= 7;
		i++;
	}
	buf->Write((char) v);
	return i + 1;
}

int16_t ESNPCoder::readInt16(ESNPBuffer *buf, int* err) {
	return (int16_t) readInt64(buf, err);
}

int ESNPCoder::writeInt16(ESNPBuffer *buf, int16_t v) {
	return writeInt64(buf, (int64_t) v);
}

int32_t ESNPCoder::readInt32(ESNPBuffer *buf, int* err) {
	return (int32_t) readInt64(buf, err);
}

int ESNPCoder::writeInt32(ESNPBuffer *buf, int32_t v) {
	return writeInt64(buf, (int64_t) v);
}

int64_t ESNPCoder::readInt64(ESNPBuffer *buf, int* err) {
	uint64_t l = readUint64(buf, err);
	int64_t l2 = (int64_t) (l >> 1);
	if((l & 1) != 0){
		l2 = ~l2;
	}
	return l2;
}

int ESNPCoder::writeInt64(ESNPBuffer *buf, int64_t v) {
	uint64_t l1 = v << 1;
	if(v < 0){
		l1 = ~l1;
	}
	return writeUint64(buf, l1);
}

std::string ESNPCoder::readString(ESNPBuffer *buf, int* err) {
	int c = buf->Remain();
	if(c==0) {
		return std::string();
	}
	std::string s;
	s.resize(c);
	buf->ReadBytes(&s[0], c);
	return s;
}

int ESNPCoder::writeString(ESNPBuffer* buf, std::string v) {
	return buf->WriteBytes(v.c_str(), v.length());
}

std::string ESNPCoder::readLenString(ESNPBuffer *buf, int* err) {
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

int ESNPCoder::writeLenString(ESNPBuffer* buf, std::string v) {
	int l = writeInt32(buf, v.length());
	return writeString(buf, v)+l;	
}

bool ESNPCoder::readVar(ESNPBuffer *buf,CCValueBuilder* vb, int* err) {
	int ty = buf->Read();
	if(ty<0) {
		if(err!=NULL)*err=ty;
		return false;
	}
	int merr = 0;
	int *perr = err==NULL?&merr:err;
	switch(ty) {
	case VVT_BOOLEAN: {
			bool v = readBool(buf, perr);
			if(*perr!=0)return false;
			vb->beBoolean(v);
			return true;
		}
		break;	
	case VVT_INT:
	case VVT_INT32: {
			int32_t v = readInt32(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_INT8: {
			int8_t v = readFixInt8(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_UINT8:{
			uint8_t v = readFixUint8(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_INT16:{
			int16_t v = readInt16(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_INT64:{
			int64_t v = readInt64(buf, perr);
			if(*perr!=0)return false;
			// TODO
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_UINT16:{
			uint16_t v = readUint16(buf, perr);
			if(*perr!=0)return false;
			// TODO
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_UINT32:{
			uint32_t v = readUint32(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_UINT64:{
			uint64_t v = readUint64(buf, perr);
			if(*perr!=0)return false;
			vb->beInt(v);
			return true;
		}
		break;
	case VVT_FLOAT32:{
			float v = readFloat32(buf, perr);
			if(*perr!=0)return false;
			vb->beNumber(v);
			return true;
		}
		break;
	case VVT_FLOAT64:{
			double v = readFloat64(buf, perr);
			if(*perr!=0)return false;
			vb->beNumber(v);
			return true;
		}
		break;
	case VVT_MAP: {
			int32_t c = readInt32(buf, perr);
			if(*perr!=0)return false;
			vb->mapBegin();			
			for(int32_t i=0;i<c;i++) {
				std::string key = readLenString(buf, perr);
				if(*perr!=0) {
					vb->mapEnd();
					return false;
				}				
				if(!readVar(buf, vb, perr)) {
					vb->mapEnd();
					return false;
				}
				vb->addMap(key.c_str());
			}
			vb->mapEnd();
			return true;
		}
		break;
	case VVT_LIST: {
			int32_t c = readInt32(buf, perr);
			if(*perr!=0)return false;
			vb->arrayBegin();			
			for(int32_t i=0;i<c;i++) {
				if(!readVar(buf, vb, perr)) {
					vb->arrayEnd();
					return false;
				}
				vb->addArray();
			}
			vb->arrayEnd();
			return true;
		}
		break;
	case VVT_LEN_STRING:	{
			std::string s = readString(buf, perr);
			if(*perr!=0)return false;
			vb->beString(s);
			return true;
		}
		break;
	}
	return false;
}

int ESNPCoder::writeVar(ESNPBuffer* buf, CCValue& val) {
	int l1,l2;
	l1 = l2 = 0;
	switch(val.getType()) {
	case CCValueTypeInt:
		l1 = buf->Write(VVT_INT32);
		l2 = writeInt32(buf, val.intValue());
		return l1+l2;
	case CCValueTypeNumber:
		l1 = buf->Write(VVT_INT32);
		l2 = writeFloat64(buf, val.numberValue());
		return l1+l2;
		break;
	case CCValueTypeBoolean:
		l1 = buf->Write(VVT_BOOLEAN);
		l2 = writeBool(buf, val.booleanValue());
		return l1+l2;		
	case CCValueTypeString:
		l1 = buf->Write(VVT_LEN_STRING);
		l2 = writeLenString(buf, val.stringValue());
		return l1+l2;		
	case CCValueTypeMap: {
		CCValueMap* m = val.mapValue();
		if(!m->empty()) {
			l1 = buf->Write(VVT_MAP);
			int c = m->size();
			l2 = writeInt32(buf, (int32_t) c);
			CCValueMapIterator it;
			for(it=m->begin();it!=m->end();it++) {
				l2 += writeLenString(buf, it->first);
				l2 += writeVar(buf, (CCValue&) *it);
			}
			return l1+l2;
		}
	}
	case CCValueTypeArray: {
			CCValueArray* a = val.arrayValue();
			if(!a->empty()) {
				l1 = buf->Write(VVT_LIST);
				int c = a->size();
				l2 = writeInt32(buf, (int32_t) c);
				CCValueArrayIterator it;
				for(it=a->begin();it!=a->end();it++) {
					l2 += writeVar(buf, (CCValue&) *it);
				}
				return l1+l2;
			}
		}
	default:
		break;
	}
	return buf->Write(VVT_NULL);
}

void ESNPCoder::header(char* buf, int mt, int sz) {
	buf[0] = (char) mt;
	buf[1] = (char) (sz >> 16);
	buf[2] = (char) (sz >> 8);
	buf[3] = (char) (sz);
}

bool ESNPCoder::header(ESNPBuffer* buf, int* mt, int* sz) {
	if(buf->Remain()<4) {
		return false;
	}
	*mt = buf->Read();
	int v = 0;
	v +=(buf->Read() & 0xFF) << 16;
	v +=(buf->Read() & 0xFF) << 8;
	v +=(buf->Read() & 0xFF);
	if(buf->Remain()<v) {
		return false;
	}
	*sz = v;	
	return true;
}